require "spec_helper"

module ParseFasta
  describe SeqFile do
    let(:test_dir) {
      File.join File.dirname(__FILE__), "..", "test_files"
    }

    let(:fasta) {
      File.join test_dir, "seqs.fa"
    }
    let(:fasta_gz) {
      File.join test_dir, "seqs.fa.gz"
    }
    let(:fastq) {
      File.join test_dir, "seqs.fq"
    }
    let(:fastq_gz) {
      File.join test_dir, "seqs.fq.gz"
    }
    let(:with_rec_sep_in_seq) {
      File.join test_dir, "with_rec_sep_in_seq.fa"
    }

    let(:fasta_records) {
      [Record.new(header: "empty seq at beginning",
                  seq: ""),
       Record.new(header: "seq1 is fun",
                  seq: "AACTGGNNN"),
       Record.new(header: "seq2",
                  seq: "AATCCTGNNN"),
       Record.new(header: "empty seq 1",
                  seq: ""),
       Record.new(header: "empty seq 2",
                  seq: ""),
       Record.new(header: "seq3",
                  seq: "yyyyyyyyyyyyyyyNNN"),
       Record.new(header: "seq 4 > has many '>' in header",
                  seq: "ACTGactg"),
       Record.new(header: "empty seq at end",
                  seq: "")]
    }
    let(:fastq_records) {
      [Record.new(header: "seq1",
                  seq: "AA CC TT GG",
                  desc: "",
                  qual: ")# 3g Tq N8"),
       Record.new(header: "seq2 @pples",
                  seq:    "ACTG",
                  desc:   "seq2 +pples",
                  qual:   "*ujM")]
    }
    let(:with_rec_sep_in_seq_records) {
      [Record.new(header: "seq1",
                  seq: "AAAA>TTTT",
                  check_fasta_seq: false),
       Record.new(header: "seq2",
                  seq: "TTTT>AAAA",
                  check_fasta_seq: false)]
    }

    # to test the line endings
    let(:line_endings_fastq_records) {
      [Record.new(header: "apple", seq: "ACTG", desc: "", qual: "IIII"),
       Record.new(header: "pie",   seq: "AACC", desc: "", qual: "BBBB"),]
    }
    let(:line_endings_fasta_records) {
      [Record.new(header: "apple", seq: "ACTG"),
       Record.new(header: "pie",   seq: "AACC"),]
    }


    describe "::open" do
      context "when the file doesn't exist" do
        it "raises FileNotFoundError" do
          expect { SeqFile.open "arstoien" }.
              to raise_error ParseFasta::Error::FileNotFoundError
        end
      end

      context "when input looks like neither fastA or fastQ" do
        it "raises a DataFormatError" do
          fname = File.join test_dir, "not_a_seq_file.txt"

          expect { SeqFile.open(fname) }.
              to raise_error ParseFasta::Error::DataFormatError
        end
      end

      context "when input looks like fastA" do
        it "sets @type to :fasta" do
          expect(SeqFile.open(fasta).type).to eq :fasta
        end

        it "sets @type to :fasta (gzipped)" do
          expect(SeqFile.open(fasta_gz).type).to eq :fasta
        end
      end

      context "when input looks like fastQ" do
        it "sets @type to :fastq" do
          expect(SeqFile.open(fastq).type).to eq :fastq
        end

        it "sets @type to :fastq (gzipped)" do
          expect(SeqFile.open(fastq_gz).type).to eq :fastq
        end
      end

      it "returns a SeqFile" do
        expect(SeqFile.open fasta).to be_a SeqFile
      end
    end

    describe "#each_record" do
      shared_examples "it yields the records" do
        it "yields the records" do
          expect { |b| SeqFile.open(fname).each_record &b  }.
              to yield_successive_args(*records)
        end
      end

      context "input is fastA" do
        context "with gzipped fastA" do
          let(:fname) { File.join test_dir, "seqs.fa.gz" }
          let(:records) { fasta_records }

          include_examples "it yields the records"
        end

        context "with gzipped fastA with multiple blobs" do
          # e.g., $ gzip -c a.fa > c.fa.gz; gzip -c b.fa >> c.fa.gz
          let(:fname) { File.join test_dir, "multi_blob.fa.gz" }
          let(:records) { fasta_records + fasta_records }

          include_examples "it yields the records"
        end

        context "with non-gzipped fastA" do
          let(:fname) { File.join test_dir, "seqs.fa" }
          let(:records) { fasta_records }


          include_examples "it yields the records"
        end

        context "when the fasta file has '>' in a seq" do
          context "when the check_fasta_seq flag is false" do
            it "yields records even with '>' in the sequence" do
              expect { |b|
                SeqFile.open(with_rec_sep_in_seq,
                             check_fasta_seq: false).each_record &b
              }.to yield_successive_args(*with_rec_sep_in_seq_records)
            end
          end

          context "when the check_fasta_seq flag is default" do
            it "raises SequenceFormatError" do
              expect { |b|
                SeqFile.open(with_rec_sep_in_seq).each_record &b
              }.to raise_error ParseFasta::Error::SequenceFormatError
            end
          end
        end
      end

      context "input is fastQ" do
        context "with gzipped fastQ" do
          let(:fname) { File.join test_dir, "seqs.fq.gz" }
          let(:records) { fastq_records }

          include_examples "it yields the records"
        end

        context "with gzipped fastQ with multiple blobs" do
          # e.g., $ gzip -c a.fq > c.fq.gz; gzip -c b.fq >> c.fq.gz
          let(:fname) { File.join test_dir, "multi_blob.fq.gz" }
          let(:records) { fastq_records + fastq_records }

          include_examples "it yields the records"
        end

        context "with non-gzipped fastQ" do
          let(:fname) { File.join test_dir, "seqs.fq" }
          let(:records) { fastq_records }

          include_examples "it yields the records"
        end
      end

      context "handles non newline line endings" do
        context "fastQ, non-gz, carriage return only" do
          let(:fname) { File.join test_dir, "cr.fq" }
          let(:records) { line_endings_fastq_records }

          include_examples "it yields the records"
        end

        context "fastQ, gz, carriage return only" do
          let(:fname) { File.join test_dir, "cr.fq.gz" }
          let(:records) { line_endings_fastq_records }

          include_examples "it yields the records"
        end

        context "fastQ, non-gz, carriage return and newline" do
          let(:fname) { File.join test_dir, "cr_nl.fq" }
          let(:records) { line_endings_fastq_records }

          include_examples "it yields the records"
        end

        context "fastQ, gz, carriage return and newline" do
          let(:fname) { File.join test_dir, "cr_nl.fq.gz" }
          let(:records) { line_endings_fastq_records }

          include_examples "it yields the records"
        end

        context "fastA, non-gz, carriage return only" do
          let(:fname) { File.join test_dir, "cr.fa" }
          let(:records) { line_endings_fasta_records }

          include_examples "it yields the records"
        end

        context "fastA, gz, carriage return only" do
          let(:fname) { File.join test_dir, "cr.fa.gz" }
          let(:records) { line_endings_fasta_records }

          include_examples "it yields the records"
        end

        context "fastA, non-gz, carriage return and newline" do
          let(:fname) { File.join test_dir, "cr_nl.fa" }
          let(:records) { line_endings_fasta_records }

          include_examples "it yields the records"
        end

        context "fastA, gz, carriage return and newline" do
          let(:fname) { File.join test_dir, "cr_nl.fa.gz" }
          let(:records) { line_endings_fasta_records }

          include_examples "it yields the records"
        end
      end
    end
  end
end
