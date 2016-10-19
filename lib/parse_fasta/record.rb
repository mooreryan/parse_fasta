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

module ParseFasta
  class Record
    attr_accessor :header, :seq, :desc, :qual

    def initialize args = {}
      @header = args.fetch :header

      @desc = args.fetch :desc, nil
      @qual = args.fetch :qual, nil

      @qual.gsub!(/\s+/, "") if @qual

      seq = args.fetch(:seq).gsub(/\s+/, "")

      if @qual # is fastQ
        @seq = seq
      else # is fastA
        @seq = check_fasta_seq(seq)
      end
    end

    def == rec
      self.header == rec.header && self.seq == rec.seq
    end

    private

    def check_fasta_seq seq
      if seq.match ">"
        raise ParseFasta::Error::SequenceFormatError,
              "A sequence contained a '>' character " +
                  "(the fastA file record separator)"
      else
        seq
      end
    end
  end
end
