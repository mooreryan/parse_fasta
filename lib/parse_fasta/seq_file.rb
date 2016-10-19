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

def get_first_char fname
  File.open(fname) do |f|
    return f.each_char.peek[0]
  end
end

def check_file fname
  first_char = get_first_char fname

  unless first_char == ">" || first_char == "@"
    raise ParseFasta::Error::DataFormatError
  end
end

module ParseFasta
  class SeqFile < File
    def self.open fname, *args
      check_file fname

      super
    end

    def each_record
      header = ""
      sequence = ""
      self.each_line do |line|
        line.chomp!
        len = line.length

        if header.empty? && line.start_with?(">")
          header = line[1, len]
        elsif line.start_with? ">"
          yield Record.new header.strip, sequence

          header = line[1, len]
          sequence = ""
        else
          # raise ParseFasta::Error::SequenceFormatError if sequence.include? ">"
          sequence << line
        end
      end
      # yield the final seq
      yield Record.new header, sequence

    end
  end
end
