#include <ruby.h>

/* static VALUE pfa_new_record(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE); */
static VALUE pfa_new_record(VALUE, VALUE, VALUE);

VALUE pfa_mParseFasta;
VALUE pfa_cRecord;
VALUE pfa_cSeqFile;

/* static void pfa_chomp(VALUE str) */
/* { */
/*   long len   = RSTRING_LEN(str); */
/*   char * end = RSTRING_END(str); */

/*   if (*(end-1) == '\n' || *(end-1) == '\r') { */
/*     rb_str_set_len(str, len-1); */
/*   } */
/* } */

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

  rb_funcall(line, rb_intern("chomp!"), 0);

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
pfa_parse_fastq_line(VALUE self,
                     VALUE line,
                     VALUE header,
                     VALUE seq,
                     VALUE desc,
                     VALUE qual,
                     VALUE count)
{
  rb_funcall(line, rb_intern("chomp!"), 0);

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
  VALUE ary = rb_funcall(header, rb_intern("split"), 1, rb_str_new_literal(" "));

  return rb_ary_entry(ary, 0);
}

static void
pfa_remove_whitespace_bang(VALUE str)
{
  rb_funcall(str,
             rb_intern("tr!"),
             2,
             rb_str_new_literal(" \t\n\r"),
             rb_str_new_literal(""));
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

  pfa_remove_whitespace_bang(seq);

  if (!NIL_P(qual)) {
    pfa_remove_whitespace_bang(qual);
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
