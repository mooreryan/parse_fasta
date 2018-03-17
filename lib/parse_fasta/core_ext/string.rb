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
  module CoreExt
    module String

      # Removes all gap chars from the string.
      #
      # @example Remove all '-' from string
      #   # First inclued the methods
      #   String.include ParseFasta::CoreExt::String
      #
      #   "--A-C-t-g".remove_gaps #=> "ACtg"
      #
      # @example Change the gap character to 'n'
      #   # First inclued the methods
      #   String.include ParseFasta::CoreExt::String
      #
      #   "-N-nACTG".remove_gaps "N" #=> "--nACTG"
      #
      # @param gap_char [String] the character to treat as a gap
      #
      # @return [String] a string with all instances of
      #   gap_char_removed
      def remove_gaps gap_char="-"
        self.tr gap_char, ""
      end
    end
  end
end
