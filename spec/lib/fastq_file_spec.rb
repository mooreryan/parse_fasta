# Copyright 2014, 2015 Ryan Moore
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

require 'spec_helper'

describe FastqFile do
  let(:records) {
    [["seq1", "AACCTTGG", "", ")#3gTqN8"],
     ["seq2 apples", "ACTG", "seq2 apples", "*ujM"]]
  }

  let(:records_fast) {
    [["seq1", "AA CC TT GG", "", ")# 3g Tq N8"],
     ["seq2 apples", "ACTG", "seq2 apples", "*ujM"]]
  }

  let(:f_handle) { FastqFile.open(@fname).each_record { |s| } }


  shared_examples_for "any FastqFile" do
    it "yields proper header, sequence, description, and quality" do
      expect { |b|
        FastqFile.open(@fname).each_record(&b)
      }.to yield_successive_args(records[0], records[1])
    end

    it "yields the sequence as a Sequence class" do
      FastqFile.open(@fname).each_record do |_, seq, _, _|
        expect(seq).to be_an_instance_of Sequence
      end
    end

    it "yields the quality as a Quality class" do
      FastqFile.open(@fname).each_record do |_, _, _, qual|
        expect(qual).to be_an_instance_of Quality
      end
    end
  end

  describe "#each_record_fast" do
    before(:each) do
      @fname = "#{File.dirname(__FILE__)}/../../test_files/test.fq.gz"
    end

    it "yields proper header, sequence, description, and quality" do
      expect { |b|
        FastqFile.open(@fname).each_record_fast(&b)
      }.to yield_successive_args(records_fast[0], records_fast[1])
    end

    it "yields all params as String" do
      FastqFile.open(@fname).each_record_fast do |h, s, d, q|
        expect(h).to be_an_instance_of String
        expect(s).to be_an_instance_of String
        expect(d).to be_an_instance_of String
        expect(q).to be_an_instance_of String
      end
    end
  end

  describe "#to_hash" do
    let(:records) {
      { "seq1" => { head: "seq1",
                    seq: "AACCTTGG",
                    desc: "",
                    qual: ")#3gTqN8" },
        "seq2 apples" => { head: "seq2 apples",
                           seq: "ACTG",
                           desc: "seq2 apples",
                           qual: "*ujM" }
      }
    }
    let(:fname) { "#{File.dirname(__FILE__)}/../../test_files/test.fq.gz" }
    let(:fastq) { FastqFile.open(fname) }

    it "reads the records into a hash: header as key and seq as val" do
      expect(fastq.to_hash).to eq records
    end

    it "passes the seqs as Sequence objects" do
      expect(
        fastq.to_hash.values.all? { |val| val[:seq].instance_of? Sequence }
      ).to eq true
    end

    it "passes the quals as Quality objects" do
      expect(
        fastq.to_hash.values.all? { |val| val[:qual].instance_of? Quality }
      ).to eq true
    end
  end

  context "with a 4 line per record fastq file" do
    describe "#each_record" do
      context "with a gzipped file" do
        before(:each) do
          @fname = "#{File.dirname(__FILE__)}/../../test_files/test.fq.gz"
        end

        it_behaves_like "any FastqFile"

        it "closes the GzipReader" do
          expect(f_handle).to be_closed
        end

        it "returns GzipReader object" do
          expect(f_handle).to be_an_instance_of Zlib::GzipReader
        end
      end

      context "with a non-gzipped file" do
        before(:each) do
          @fname = "#{File.dirname(__FILE__)}/../../test_files/test.fq"
        end

        it_behaves_like "any FastqFile"

        it "doesn't close the FastqFile (approx regular file behavior)" do
          expect(f_handle).not_to be_closed
        end

        it "returns FastqFile object" do
          expect(f_handle).to be_an_instance_of FastqFile
        end
      end
    end
  end
end
