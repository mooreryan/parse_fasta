#include <ruby.h>
#include <ctype.h>
#include "bstrlib.h"

/* static VALUE pfa_new_record(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE); */
static VALUE pfa_new_record(VALUE, VALUE, VALUE);

VALUE pfa_mParseFasta;
VALUE pfa_cRecord;
VALUE pfa_cSeqFile;

static void pfa_chomp_bang(VALUE str)
{
  long len   = RSTRING_LEN(str);
  char * end = RSTRING_END(str);

  if (*(end-1) == '\r') {
    rb_str_set_len(str, len-1);
  } else if (*(end-1) == '\n') {
    if (*(end-2) == '\r') {
      rb_str_set_len(str, len-2);
    } else {
      rb_str_set_len(str, len-1);
    }
  }
}

static int pfa_is_empty(VALUE str)
{
  return !RSTRING_LEN(str);
}

static int pfa_is_header(VALUE str)
{
  char * ptr = RSTRING_PTR(str);

  return *ptr == '>';
}

static VALUE pfa_drop_first_char(VALUE str)
{
  char * ptr = RSTRING_PTR(str);

  return rb_str_new_cstr(ptr+1);
}

static VALUE pfa_lstrip(VALUE str)
{
  char * start = RSTRING_PTR(str);
  char * end = RSTRING_END(str);

  while (start < end && ISSPACE(*start)) {
    ++start;
  }

  long offset = start - RSTRING_PTR(str);

  return rb_str_new_cstr(RSTRING_PTR(str) + offset);
}

static VALUE pfa_rstrip(VALUE str)
{

  char * start = RSTRING_PTR(str);
  char * end = RSTRING_END(str);

  while (end > start && (ISSPACE(*end) || (*end == '\0'))) {
    --end;
  }

  /* subtract one to not chop off '\0' at end */
  long offset = RSTRING_END(str) - end - 1;

  return rb_str_subseq(str, 0, RSTRING_LEN(str) - offset);
}

static VALUE pfa_strip(VALUE str)
{
  return pfa_lstrip(pfa_rstrip(str));
}

static VALUE
pfa_parse_fasta_line(VALUE self,
                     VALUE line,
                     VALUE header,
                     VALUE sequence,
                     VALUE exception)
{

  /* rb_funcall(line, rb_intern("chomp!"), 0); */
  pfa_chomp_bang(line);

  if (pfa_is_empty(header) && pfa_is_header(line)) {
    // drop the >
    header = pfa_drop_first_char(line);
  } else if (pfa_is_header(line)) {
    VALUE hash = rb_hash_new();
    rb_hash_aset(hash, rb_to_symbol(rb_str_new2("header")), pfa_strip(header));
    rb_hash_aset(hash, rb_to_symbol(rb_str_new2("seq")), sequence);
    VALUE record = rb_class_new_instance(1, &hash, pfa_cRecord);

    rb_yield_values(1, record);

    header   = pfa_drop_first_char(line);
    sequence = rb_str_new_literal("");
  } else {
    rb_str_cat_cstr(sequence, RSTRING_PTR(line));
  }

  return rb_ary_new_from_args(2, header, sequence);
}

static VALUE
pfa_each_line(VALUE self, VALUE fname)
{
  bstring str = bfromcstr("");
  char line_term = '\n';
  struct bStream *bstream;
  FILE *fp;
  char *cstr;
  int i;

  fp = fopen(StringValueCStr(fname), "r");
  if (fp == NULL) perror ("Error opening file");
  bstream = bsopen((bNread) fread, fp);

  while ((i = bsreadln(str, bstream, line_term)) != EOF && i != BSTR_ERR) {
    cstr = bstr2cstr(str, '0');
    rb_yield(rb_str_new_cstr(cstr));
  }

  bsclose(bstream);
  fclose(fp);
  bdestroy(str);

  return Qnil;
}

static VALUE
pfa_each_record_fastq_fast(VALUE self, VALUE fname)
{
  int i;
  long lineno = 0;
  char line_term = '\n';

  bstring line   = bfromcstr("");
  bstring header = bfromcstr("");
  bstring seq    = bfromcstr("");
  bstring desc   = bfromcstr("");
  bstring qual   = bfromcstr("");

  FILE *fp;
  struct bStream *bstream;

  fp = fopen(StringValueCStr(fname), "r");
  if (fp == NULL) perror ("Error opening file");
  bstream = bsopen((bNread) fread, fp);

  while ((i = bsreadln(line, bstream, line_term)) != EOF && i != BSTR_ERR) {
    brtrimws(line);

    switch (lineno) {
    case 0:
      header = bmidstr(line, 1, blength(line));
      break;
    case 1:
      seq = bstrcpy(line);
      break;
    case 2:
      desc = bmidstr(line, 1, blength(line));
      break;
    case 3:
      lineno = -1;
      qual = bstrcpy(line);

      VALUE hash = rb_hash_new();
      rb_hash_aset(hash,
                   rb_to_symbol(rb_str_new2("header")),
                   rb_str_new_cstr(bstr2cstr(header, '0')));
      rb_hash_aset(hash,
                   rb_to_symbol(rb_str_new2("seq")),
                   rb_str_new_cstr(bstr2cstr(seq, '0')));
      rb_hash_aset(hash,
                   rb_to_symbol(rb_str_new2("desc")),
                   rb_str_new_cstr(bstr2cstr(desc, '0')));
      rb_hash_aset(hash,
                   rb_to_symbol(rb_str_new2("qual")),
                   rb_str_new_cstr(bstr2cstr(qual, '0')));

      VALUE record = rb_class_new_instance(1, &hash, pfa_cRecord);

      rb_yield_values(1, record);

      break;
    default:
      fprintf(stderr,
              "ERROR -- parse_fasta.c in pfa_parse_fastq_line: "
              "in the default!\n");
      exit(1);
    }

    ++lineno;

  }

  bsclose(bstream);
  fclose(fp);

  bdestroy(line);
  bdestroy(header);
  bdestroy(seq);
  bdestroy(desc);
  bdestroy(qual);

  return Qnil;
}


static VALUE
pfa_parse_fastq_line(VALUE self,
                     VALUE line,
                     VALUE header,
                     VALUE seq,
                     VALUE desc,
                     VALUE qual,
                     VALUE count)
{
  /* rb_funcall(line, rb_intern("chomp!"), 0); */
  pfa_chomp_bang(line);

  long line_count = NUM2LONG(count);

  switch (line_count) {
  case 0:
    header = pfa_drop_first_char(line);
    break;
  case 1:
    seq = line;
    break;
  case 2:
    desc = pfa_drop_first_char(line);
    break;
  case 3:
    line_count = -1;
    qual = line;

    VALUE hash = rb_hash_new();
    rb_hash_aset(hash, rb_to_symbol(rb_str_new2("header")), header);
    rb_hash_aset(hash, rb_to_symbol(rb_str_new2("seq")), seq);
    rb_hash_aset(hash, rb_to_symbol(rb_str_new2("desc")), desc);
    rb_hash_aset(hash, rb_to_symbol(rb_str_new2("qual")), qual);
    VALUE record = rb_class_new_instance(1, &hash, pfa_cRecord);

    rb_yield_values(1, record);

    break;
  default:
    fprintf(stderr,
            "ERROR -- parse_fasta.c in pfa_parse_fastq_line: "
            "in the default!\n");
    exit(1);
  }

  ++line_count;

  return rb_ary_new_from_args(5,
                              header,
                              seq,
                              desc,
                              qual,
                              LONG2NUM(line_count));
}




static VALUE
pfa_is_fasta_seq_bad(VALUE self, VALUE str)
{
  char * ptr = RSTRING_PTR(str);
  long len   = RSTRING_LEN(str);
  long i     = 0;

  for (i = 0; i < len; ++i) {
    if (ptr[i] == '>') {
      return Qtrue;
    }
  }

  return Qfalse;
}


static VALUE
pfa_id_from_header(VALUE header)
{
  /* VALUE ary = rb_funcall(header, rb_intern("split"), 1, rb_str_new_literal(" ")); */

  /* return rb_ary_entry(ary, 0); */

  char * str = StringValueCStr(header);
  long len = RSTRING_LEN(header);
  long i = 0;

  for (i = 0; i < len && !isspace(str[i]); ++i) {
    ;
  }

  return rb_str_new(str, i);
}

/* static void */
/* pfa_remove_whitespace_bang(VALUE str) */
/* { */
/*   rb_funcall(str, */
/*              rb_intern("tr!"), */
/*              2, */
/*              rb_str_new_literal(" \t\n\r"), */
/*              rb_str_new_literal("")); */
/* } */

static VALUE
pfa_remove_whitespace(VALUE str)
{
  char * s = StringValueCStr(str);
  long len = RSTRING_LEN(str);
  long i = 0;
  long new_s_idx = 0;
  char new_s[len+1];
  char c;

  for (i = 0; i < len; ++i) {
    c = s[i];
    if (!isspace(c)) {
      new_s[new_s_idx++] = c;
    }
  }

  new_s[new_s_idx] = '\0';

  return rb_str_new2(new_s);
}


/* static VALUE */
/* pfa_new_record(VALUE self, */
/*                 VALUE header, */
/*                 VALUE seq, */
/*                 VALUE desc, */
/*                 VALUE qual, */
/*                 VALUE exception) */
static VALUE
pfa_new_record(VALUE self,
               VALUE hash,
               VALUE exception)
{

  VALUE header = rb_hash_aref(hash, rb_to_symbol(rb_str_new2("header")));
  VALUE seq    = rb_hash_aref(hash, rb_to_symbol(rb_str_new2("seq")));
  VALUE desc   = rb_hash_aref(hash, rb_to_symbol(rb_str_new2("desc")));
  VALUE qual   = rb_hash_aref(hash, rb_to_symbol(rb_str_new2("qual")));

  seq = pfa_remove_whitespace(seq);

  if (!NIL_P(qual)) {
    qual = pfa_remove_whitespace(qual);
  } else if (pfa_is_fasta_seq_bad(self, seq)) {
      rb_raise(exception,
               "A sequence contained a '>' character "
               "(the fastA file record separator)");
  }

  rb_iv_set(self, "@header", header);
  rb_iv_set(self, "@id", pfa_id_from_header(header));
  rb_iv_set(self, "@seq", seq);
  rb_iv_set(self, "@desc", desc);
  rb_iv_set(self, "@qual", qual);

  return self;
}

void pfa_init_seq_file(void)
{
  pfa_cSeqFile = rb_define_class_under(pfa_mParseFasta, "SeqFile", rb_cObject);

  rb_define_method(pfa_cSeqFile, "parse_fasta_line", pfa_parse_fasta_line, 4);
  rb_define_method(pfa_cSeqFile, "parse_fastq_line", pfa_parse_fastq_line, 6);
  rb_define_method(pfa_cSeqFile, "each_line", pfa_each_line, 1);
  rb_define_method(pfa_cSeqFile, "each_record_fastq_fast", pfa_each_record_fastq_fast, 1);
}

void pfa_init_record(void)
{
  pfa_cRecord = rb_define_class_under(pfa_mParseFasta, "Record", rb_cObject);

  rb_define_attr(pfa_cRecord, "header", 1, 1);
  rb_define_attr(pfa_cRecord, "id", 1, 1);
  rb_define_attr(pfa_cRecord, "seq", 1, 1);
  rb_define_attr(pfa_cRecord, "desc", 1, 1);
  rb_define_attr(pfa_cRecord, "qual", 1, 1);

  rb_define_method(pfa_cRecord, "create", pfa_new_record, 2);

  rb_define_method(pfa_cRecord,
                   "fasta_seq_bad?",
                   pfa_is_fasta_seq_bad,
                   1);
}

void Init_parse_fasta(void)
{
  pfa_mParseFasta = rb_define_module("ParseFasta");

  pfa_init_record();
  pfa_init_seq_file();
}
