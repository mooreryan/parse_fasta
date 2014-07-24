# Copyright 2014 Ryan Moore
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

describe FastaFile do
  describe "#each_record" do

    let(:fname) { "#{File.dirname(__FILE__)}/../../test_files/test.fa" }

    context "with no arguments" do 
      it "yields header and sequence for each record in a fasta file" do
        seqs = []
        FastaFile.open(fname, 'r').each_record do |header, sequence|
          seqs << [header, sequence]
        end
        
        expect(seqs).to eq([["seq1 is fun", "AACTGGNNN"],
                            ["seq2", "AATCCTGNNN"],
                            ["seq3", "yyyyyyyyyyyyyyyNNN"]])

      end

      it "yields sequence of type Sequence as second parameter" do
        FastaFile.open(fname, 'r').each_record do |header, sequence|
          expect(sequence).to be_an_instance_of Sequence
          break
        end
      end      
    end

    context "with a truthy argument" do
      it "yields header and array of lines for each record" do
        seqs = []
        FastaFile.open(fname, 'r').each_record(1) do |header, sequence|
          seqs << [header, sequence]
        end

        expect(seqs).to eq([["seq1 is fun", ["AACTGGNNN"]],
                            ["seq2", ["AAT", "CCTGNNN"]],
                            ["seq3", ["yyyyyyyyyy", "yyyyy", "NNN"]]])
      end
    end
  end
end
