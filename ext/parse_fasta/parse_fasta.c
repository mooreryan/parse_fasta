#include <ruby.h>

VALUE pfa_mParseFasta;
VALUE pfa_cRecord;

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

static VALUE
pfa_record_init(VALUE self,
                VALUE header,
                VALUE seq,
                VALUE desc,
                VALUE qual,
                VALUE exception)
{
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

void pfa_init_record(void)
{
  pfa_cRecord = rb_define_class_under(pfa_mParseFasta, "Record", rb_cObject);

  rb_define_attr(pfa_cRecord, "header", 1, 1);
  rb_define_attr(pfa_cRecord, "id", 1, 1);
  rb_define_attr(pfa_cRecord, "seq", 1, 1);
  rb_define_attr(pfa_cRecord, "desc", 1, 1);
  rb_define_attr(pfa_cRecord, "qual", 1, 1);

  rb_define_method(pfa_cRecord, "create", pfa_record_init, 5);

  rb_define_method(pfa_cRecord,
                   "fasta_seq_bad?",
                   pfa_is_fasta_seq_bad,
                   1);
}

void Init_parse_fasta(void)
{
  pfa_mParseFasta = rb_define_module("ParseFasta");

  pfa_init_record();
}
