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
    let(:header) { "apple pie is good"}
    let(:seq) { "ACTG" }
    let(:fasta_rec) { Record.new header: header,
                                 seq:    "A C\t\t   T   G\r" }

    describe "::new" do
      it "sets :header" do
        expect(fasta_rec.header).to eq header
      end

      it "sets :seq" do
        expect(fasta_rec.seq).to eq seq
      end

      context "when seq has a '>' in it" do
        it "raises SequenceFormatError" do
          str = "actg>sequence 3"

          expect { Record.new header: header, seq: str }.
              to raise_error ParseFasta::Error::SequenceFormatError
        end
      end
    end

    describe "#==" do
      it "returns true if each of the attr_accessors are ==" do
        rec = Record.new header: header, seq: seq

        expect(fasta_rec == rec).to eq true
      end

      it "returns false otherwise" do
        rec = Record.new header: "a", seq: "b"

        expect(fasta_rec == rec).to eq false
      end

    end
  end
end
