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

    let(:records) {
      [Record.new("empty seq at beginning", ""),
       Record.new("seq1 is fun", "AACTGGNNN"),
       Record.new("seq2", "AATCCTGNNN"),
       Record.new("empty seq 1", ""),
       Record.new("empty seq 2", ""),
       Record.new("seq3", "yyyyyyyyyyyyyyyNNN"),
       Record.new("seq 4 > has many '>' in header", "ACTGactg"),
       Record.new("empty seq at end", "")]
    }

    describe "::open" do
      context "when input looks like neither fastA or fastQ" do
        it "raises a DataFormatError" do
          fname = File.join test_dir, "not_a_seq_file.txt"

          expect { SeqFile.open(fname) }.
            to raise_error ParseFasta::Error::DataFormatError
        end
      end

      it "takes all the wacky args like IO.open" do
        expect {
          SeqFile.open fasta, mode: 'r', cr_newline: true
        }.not_to raise_error
      end

      it "returns a SeqFile" do
        expect(SeqFile.open fasta).to be_a SeqFile
      end
    end

    describe "#each_record" do
      context "fastA input" do
        it "yields header and sequence for each record" do
          expect { |b| SeqFile.open(fasta).each_record &b  }.
              to yield_successive_args(*records)
        end
      end
    end
  end
end
