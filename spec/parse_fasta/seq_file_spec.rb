# Copyright 2014 - 2016 Ryan Moore
# Contact: moorer@udel.edu
#
# This file is part of parse_fasta.
#
# parse_fasta is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# parse_fasta is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with parse_fasta.  If not, see <http://www.gnu.org/licenses/>.

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

    describe "::open" do
      context "when the file doesn't exist" do
        it "raises something"
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
    end
  end
end