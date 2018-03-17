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
  module CoreExt
    describe String do
      Object::String.include ParseFasta::CoreExt::String

      describe "#remove_gaps" do
        it "removes all gaps from alignment" do
          aln = "--A----C-tG---"
          expected = "ACtG"

          expect(aln.remove_gaps).to eq expected
        end

        it "returns empty string if all chars are gap chars" do
          aln = "-----"
          expected = ""

          expect(aln.remove_gaps).to eq expected
        end

        it "can take a different gap char" do
          aln = "-N-nACTG"
          expected = "--nACTG"

          expect(aln.remove_gaps "N").to eq expected
        end
      end
    end
  end
end
