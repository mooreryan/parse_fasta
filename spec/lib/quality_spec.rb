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
require 'bio'

describe Quality do
  let(:qual_string) { qual_string = Quality.new('ab%63:K') }
  let(:bioruby_qual_scores) do 
    Bio::Fastq.new("@seq1\nACTGACT\n+\n#{qual_string}").quality_scores
  end

  describe "#qual_scores" do
    context "with illumina style quality scores" do
      it "returns an array of quality scores" do
        expect(qual_string.qual_scores).to eq bioruby_qual_scores
      end
    end
  end
end
