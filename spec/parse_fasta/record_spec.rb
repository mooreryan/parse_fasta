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
  describe Record do
    let(:header)  { "apple pie is good"}
    let(:id)      { "apple" }
    let(:seq)     { "ACTG" }
    let(:desc)    { "apple" }
    let(:qual)    { "abcd" }

    let(:fasta_rec) {
      Record.new header: header,
                 seq:    "A \r\n\r\n\tC\t\t \n  T   G\r"
    }
    let(:fastq_rec) {
      Record.new header: header,
                 seq:    "A \r\n\r\n\tC\t\t \n  T   G\r",
                 desc:   desc,
                 qual:   " a  b \tcd "
    }

    describe "::new" do
      context "either fastA or fastQ" do
        it "sets :header" do
          expect(fasta_rec.header).to eq header
          expect(fastq_rec.header).to eq header
        end

        it "sets :seq" do
          expect(fasta_rec.seq).to eq seq
          expect(fastq_rec.seq).to eq seq
        end

        it "sets :id" do
          expect(fasta_rec.id).to eq id
          expect(fastq_rec.id).to eq id
        end

        it "sets :id to the first token when split by whitespace" do
          rec = Record.new header: "apple\tpie is good",
                           seq: "actg"

          expect(rec.id).to eq "apple"
        end
      end

      context "fastA input" do
        it "sets :desc to nil" do
          expect(fasta_rec.desc).to eq nil
        end

        it "sets :qual to nil" do
          expect(fasta_rec.qual).to eq nil
        end

        context "when seq has a '>' in it" do
          it "raises SequenceFormatError" do
            str = "actg>sequence 3"

            expect { Record.new header: header, seq: str }.
                to raise_error ParseFasta::Error::SequenceFormatError
          end
        end
      end

      context "fastQ input" do
        it "sets :desc to desc" do
          expect(fastq_rec.desc).to eq desc
        end

        it "sets :qual to qual" do
          expect(fastq_rec.qual).to eq qual
        end

        context "when seq has a '>' in it" do
          it "does NOT rais SequenceFormatError" do
            str = "actg>sequence 3"

            expect { Record.new header: header,
                                seq:    str,
                                desc:   desc,
                                qual:   qual }.
                not_to raise_error
          end
        end
      end
    end

    describe "#==" do
      it "returns true if each of the attr_accessors are ==" do
        rec1 = Record.new header: "a", seq: "a", desc: "", qual: "A"
        rec2 = Record.new header: "a", seq: "a", desc: "", qual: "A"

        expect(rec1 == rec2).to eq true
      end

      it "returns false otherwise" do
        rec1 = Record.new header: "a", seq: "a", desc: "", qual: "A"
        rec2 = Record.new header: "a", seq: "a", desc: "", qual: "b"

        expect(rec1 == rec2).to eq false
      end
    end

    describe "#fastq?" do
      it "returns true if @qual is not nil" do
        rec = Record.new header: "a", seq: "a", qual: "a"

        expect(rec.fastq?).to eq true
      end

      it "returns nil if @qual is nil" do
        rec = Record.new header: "a", seq: "a"

        expect(rec.fastq?).to eq nil
      end
    end

    describe "#to_s" do
      context "when the record is fastA like" do
        it "returns a string of the fastA record ready to print" do
          rec = Record.new header: "apple", seq: "actg"

          expect(rec.to_s).to eq ">apple\nactg"
        end
      end

      context "when the record is fastQ like" do
        it "returns a string of the fastQ record ready to print" do
          rec = Record.new header: "apple", seq: "actg", desc: "", qual: "IIII"

          expect(rec.to_s).to eq "@apple\nactg\n+\nIIII"
        end
      end
    end

    describe "#to_fasta" do
      context "when the record is fastA like" do
        it "returns a string of the fastA record ready to print" do
          rec = Record.new header: "apple", seq: "actg"

          expect(rec.to_fasta).to eq ">apple\nactg"
        end
      end

      context "when the record is fastQ like" do
        it "returns a string of the fastQ record in fastA format" do
          rec = Record.new header: "apple", seq: "actg", desc: "", qual: "IIII"

          expect(rec.to_fasta).to eq ">apple\nactg"
        end
      end
    end

    describe "#to_fastq" do
      context "when the record is fastA like" do
        let(:rec) {Record.new header: "apple", seq: "actg"}

        it "has a default quality string (I) and description" do
          expect(rec.to_fastq).to eq "@apple\nactg\n+\nIIII"
        end

        context "specifying values for qual string" do
          it "can specify the qual string value (single value)" do
            expect(rec.to_fastq qual: "A").to eq "@apple\nactg\n+\nAAAA"
          end

          it "can specify complex qual string values (uneven division)" do
            seq  = "actgactgactgactg"
            qual = "1@c1@c1@c1@c1@c1"
            rec = Record.new header: "apple", seq: seq

            expect(rec.to_fastq qual: "1@c").to eq "@apple\n#{seq}\n+\n#{qual}"
          end

          it "can specify complex qual string values (even division)" do
            seq  = "actgactgactgactg"
            qual = "a1a1a1a1a1a1a1a1"
            rec = Record.new header: "apple", seq: seq

            expect(rec.to_fastq qual: "a1").to eq "@apple\n#{seq}\n+\n#{qual}"
          end

          it "can specify complex qual string values (full length)" do
            seq  = "actgactgactgactg"
            qual = "a1a1a1a1a1a1a1a1"
            rec = Record.new header: "apple", seq: seq

            expect(rec.to_fastq qual: qual).to eq "@apple\n#{seq}\n+\n#{qual}"
          end

          it "raises ParseFasta::Error::ArgumentError when :qual is empty" do
            seq  = "actgactgactgactg"
            qual = "IIIIIIIIIIIIIIII"
            rec = Record.new header: "apple", seq: seq

            expect{rec.to_fastq qual: ""}.to raise_error ParseFasta::Error::ArgumentError
          end
        end

        it "can specify the description" do
          expect(rec.to_fastq desc: "pie").to eq "@apple\nactg\n+pie\nIIII"
        end

        it "can specify the both" do
          expect(rec.to_fastq qual: "A", desc: "pie").to eq "@apple\nactg\n+pie\nAAAA"
        end
      end

      context "when the record is fastQ like" do
        it "returns a string of the fastQ format" do
          rec = Record.new header: "apple", seq: "actg", desc: "", qual: "IIII"

          expect(rec.to_fastq).to eq "@apple\nactg\n+\nIIII"
        end
      end
    end
  end
end
