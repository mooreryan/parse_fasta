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

require "parse_fasta/version"
require "parse_fasta/seq_file"
require "parse_fasta/error"

require "parse_fasta/parse_fasta" # The C ext
require "parse_fasta/record" # Monkey patch of C ext

module ParseFasta
  # class Record
  #   def initialize header:, seq:, desc: nil, qual: nil
  #     if qual.nil?
  #       check_fasta_seq seq
  #     end

  #     create header, seq, desc, qual
  #   end

  #   private

  #   def check_fasta_seq seq
  #     if seq.include? ">"
  #       raise ParseFasta::Error::SequenceFormatError,
  #             "A sequence contained a '>' character " +
  #                 "(the fastA file record separator)"
  #     else
  #       seq
  #     end
  #   end
  # end
end
