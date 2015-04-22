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

class SeqFile < File
  def each_record
    first_char = get_first_char(self)
    
    if first_char == '>'
      FastaFile.open(self).each_record do |header, sequence|
        yield(header, sequence)
      end
    elsif first_char == '@'
      FastqFile.open(self).each_record do |head, seq, desc, qual|
        yield(head, seq)
      end
    else
      raise ArgumentError, "Input does not look like FASTA or FASTQ"
    end      
  end

  private

  def get_first_char(f)
    begin
      handle = Zlib::GzipReader.open(f)
    rescue Zlib::GzipFile::Error => e
      handle = f
    end      

    handle.each_line.peek[0]
  end
end
