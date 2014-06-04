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
    it "yields a block with header and sequence for each record in a fasta file" do
      seqs = []
      FastaFile.open(fname, 'r').each_record do |header, sequence|
        seqs << [header, sequence]
      end
      
      expect(seqs).to eq([["seq1 is fun", "AACTGGend"],
                          ["seq2", "AATCCTGend"],
                          ["seq3", "yyyyyyyyyyyyyyyend"]])

    end

    it "passes header of type string as first parameter" do
      sequence_class = nil
      FastaFile.open(fname, 'r').each_record do |header, sequence|
        sequence_class = sequence.class
        break
      end
      expect(sequence_class).to be Sequence
    end      
  end
end
