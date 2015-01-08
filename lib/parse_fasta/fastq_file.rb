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

# Provides simple interface for parsing four-line-per-record fastq
# format files.

require 'zlib'

class FastqFile < File

  # Analagous to IO#each_line, #each_record is used to go through a
  # fastq file record by record. It will accept gzipped files as well.
  #
  # @example Parsing a fastq file
  #   FastqFile.open('reads.fq').each_record do |head, seq, desc, qual|
  #     # do some fun stuff here!
  #   end
  # @example Use the same syntax for gzipped files!
  #   FastqFile.open('reads.fq.gz').each_record do |head, seq, desc, qual|
  #     # do some fun stuff here!
  #   end
  # 
  # @yield The header, sequence, description and quality string for
  #   each record in the fastq file to the block
  # @yieldparam header [String] The header of the fastq record without
  #   the leading '@'
  # @yieldparam sequence [Sequence] The sequence of the fastq record
  # @yieldparam description [String] The description line of the fastq
  #   record without the leading '+'
  # @yieldparam quality_string [Quality] The quality string of the
  #   fastq record
  def each_record
    count = 0
    header = ''
    sequence = ''
    description = ''
    quality = ''

    begin
      f = Zlib::GzipReader.open(self)
    rescue Zlib::GzipFile::Error => e
      f = self
    end      
    
    f.each_line do |line|
      line.chomp!

      case count % 4
      when 0
        header = line.sub(/^@/, '')
      when 1
        sequence = Sequence.new(line)
      when 2
        description = line.sub(/^\+/, '')
      when 3
        quality = Quality.new(line)
        yield(header, sequence, description, quality)
      end
      
      count += 1
    end
    
    f.close if f.instance_of?(Zlib::GzipReader)
    return f
  end
end
