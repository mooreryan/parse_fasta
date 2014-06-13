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

describe FastqFile do
  describe "#each_record" do
    let(:fname) { "#{File.dirname(__FILE__)}/../../test_files/test.fq" }

    context "with a 4 line per record fastq file" do
      before do
        @records = []
        FastqFile.open(fname, 'r').each_record do |head, seq, desc, qual|
          @records << [head, seq, desc, qual]
        end
      end

      it "yields the header, sequence, desc, and qual" do
        expect(@records).to eq([["seq1", "AACCTTGG", "", ")#3gTqN8"],
                               ["seq2 apples", "ACTG", "seq2 apples",
                                "*ujM"]])
      end
      
      it "yields the sequence as a Sequence class" do
        the_sequence = @records[0][1]
        expect(the_sequence).to be_a(Sequence)
      end

      it "yields the quality string as a Quality class" do
        the_quality = @records[0][3]
        expect(the_quality).to be_a(Quality)
      end
    end
  end
end
