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
  # Contains the Error classes that ParseFasta API will raise
  module Error

    # All ParseFasta errors inherit from ParseFastaError
    class ParseFastaError < StandardError
    end

    # Raised when the input file doesn't look like fastA or fastQ
    class DataFormatError < ParseFastaError
    end

    # Raised when the file is not found
    class FileNotFoundError < ParseFastaError
    end

    # Raised when fastA sequences have a '>' in them
    class SequenceFormatError < ParseFastaError
    end
  end
end
