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
require 'bio'

describe Sequence do

  it "inherits from String" do
    expect(Sequence.new('ACTG')).to be_a String
  end

  describe "::new" do
    it "removes any spaces in the sequence" do
      s = "ACT ACT ACT    GCT  "
      s_no_spaces = "ACTACTACTGCT"
      expect(Sequence.new(s)).to eq s_no_spaces
    end
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
    context "for a DNA sequence with default or falsy argument" do
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

    context "for an RNA sequence with falsy or default argument" do
      it "returns a map of A, C, U, G counts" do
        s = Sequence.new('ACUGacug')
        expect(s.base_counts).to eq({ a: 2, c: 2, u: 2, g: 2 })
      end
    end

    context "for an RNA sequence with truthy argument" do
      it "returns a map of A, C, U, G and N counts" do
        s = Sequence.new('ACUGNacugn')
        expect(s.base_counts(1)).to eq({ a: 2, c: 2, u: 2, g: 2, n: 2 })
      end
    end

    context "for a sequence with both U and T present" do
      s = Sequence.new('AaCcTtGgNnUu')
      err_message = 'ERROR: A sequence contains both T and U'

      it "warns the user about having both U and T present" do
        expect(s).to receive(:warn).with(err_message)
        s.base_counts
      end

      it "returns a map that counts both U's and T's" do
        expect(s.base_counts).to eq({ a: 2, c: 2, t: 2, u: 2, g: 2 })
      end

      it "returns a map with T, U and N if truthy argument given" do
        base_counts = { a: 2, c: 2, t: 2, u: 2, g: 2, n: 2 }
        expect(s.base_counts(1)).to eq(base_counts)
      end
    end
  end

  describe "#base_frequencies" do
    context "with falsy argument" do
      it "doesn't count ambiguous bases in total bases" do
        s = Sequence.new('ACTTn')
        base_freqs = { a: 0.25, c: 0.25, t: 0.5, g: 0.0 }
        expect(s.base_frequencies).to eq(base_freqs)
      end
    end

    context "when counting ambiguous bases" do
      it "does count ambiguous bases in total bases" do
        s = Sequence.new('ACTTn')
        base_freqs = { a: 0.2, c: 0.2, t: 0.4, g: 0.0, n: 0.2 }
        expect(s.base_frequencies(1)).to eq(base_freqs)
      end
    end
  end
end
