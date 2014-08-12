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

describe Sequence do

  it "inherits from String" do
    expect(Sequence.new('ACTG')).to be_a String
  end

  describe "#gc" do
    it "gives the same answer as BioRuby" do
      s = 'ACtgcGAtcgCgAaTtGgCcnNuU'
      bioruby_gc = Bio::Sequence::NA.new(s).gc_content
      expect(Sequence.new(s).gc).to eq bioruby_gc
    end

    context "when sequence isn't empty" do
      it "calculates gc" do
        s = Sequence.new('ActGnu')
        expect(s.gc).to eq(2 / 5.to_f)
      end
    end

    context "when sequence is empty" do
      it "returns 0" do
        s = Sequence.new('')
        expect(s.gc).to eq 0
      end
    end

    context "there are no A, C, T, G or U (ie only N)" do
      it "returns 0" do
        s = Sequence.new('NNNNNnn')
        expect(s.gc).to eq 0
      end
    end
  end

  describe "#base_counts" do
    context "for a DNA sequence" do
      it "returns a map of A, C, T, and G counts" do
        s = Sequence.new('ACTGactg')
        expect(s.base_counts).to eq({ a: 2, c: 2, t: 2, g: 2 })
      end
    end

    context "for a DNA sequence with truthy argument" do
      it "returns a map of A, C, T, G and N counts" do
        s = Sequence.new('ACTGNactgn')
        expect(s.base_counts(1)).to eq({ a: 2, c: 2, t: 2, g: 2, n: 2 })
      end
    end

  end
end
