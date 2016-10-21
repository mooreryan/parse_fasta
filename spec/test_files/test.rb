require "parse_fasta"

fasta_records =
  [ParseFasta::Record.new(header: "empty seq at beginning",
              seq: ""),
   ParseFasta::Record.new(header: "seq1 is fun",
              seq: "AACTGGNNN"),
   ParseFasta::Record.new(header: "seq2",
              seq: "AATCCTGNNN"),
   ParseFasta::Record.new(header: "empty seq 1",
              seq: ""),
   ParseFasta::Record.new(header: "empty seq 2",
              seq: ""),
   ParseFasta::Record.new(header: "seq3",
              seq: "yyyyyyyyyyyyyyyNNN"),
   ParseFasta::Record.new(header: "seq 4 > has many '>' in header",
              seq: "ACTGactg"),
   ParseFasta::Record.new(header: "empty seq at end",
              seq: "")]

fastq_records =
  [ParseFasta::Record.new(header: "seq1",
              seq: "AA CC TT GG",
              desc: "",
              qual: ")# 3g Tq N8"),
   ParseFasta::Record.new(header: "seq2 @pples",
              seq:    "ACTG",
              desc:   "seq2 +pples",
              qual:   "*ujM")]


line_endings_fastq_records =
  [ParseFasta::Record.new(header: "apple", seq: "ACTG", desc: "", qual: "IIII"),
   ParseFasta::Record.new(header: "pie",   seq: "AACC", desc: "", qual: "BBBB"),]

line_endings_fasta_records =
  [ParseFasta::Record.new(header: "apple", seq: "ACTG"),
   ParseFasta::Record.new(header: "pie",   seq: "AACC"),]

def check fname, expected_records
  STDERR.puts "\nReading #{fname}"
  recs = []
  ParseFasta::SeqFile.open(File.join File.dirname(__FILE__), fname).each_record do |rec|
    p [rec.header, rec.seq, rec.desc, rec.qual]
    recs << rec
  end
  STDERR.puts "Good? #{recs == expected_records}"

  $results << (recs == expected_records)
end

$results = []

check "seqs.fa",    fasta_records
check "seqs.fa.gz", fasta_records
check "seqs.fq",    fastq_records
check "seqs.fq.gz", fastq_records

check "cr.fa",       line_endings_fasta_records
check "cr.fa.gz",    line_endings_fasta_records
check "cr_nl.fa",    line_endings_fasta_records
check "cr_nl.fa.gz", line_endings_fasta_records

check "cr.fq",       line_endings_fastq_records
check "cr.fq.gz",    line_endings_fastq_records
check "cr_nl.fq",    line_endings_fastq_records
check "cr_nl.fq.gz", line_endings_fastq_records

if $results.all? { |res| res }
  STDERR.puts "\nAll Good!\n\n"
end