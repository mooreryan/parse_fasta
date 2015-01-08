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

require 'zlib'

# Provides simple interface for parsing fasta format files. Gzipped
# files are no problem.
class FastaFile < File

  # Analagous to IO#each_line, #each_record is used to go through a
  # fasta file record by record. It will accept gzipped files as well.
  #
  # @param separate_lines [Object] If truthy, separate lines of record
  #   into an array of Sequences, but if falsy, yield a Sequence
  #   object for the sequence instead.
  #
  # @example Parsing a fasta file (default behavior, gzip files are fine)
  #   FastaFile.open('reads.fna.gz').each_record do |header, sequence|
  #     puts [header, sequence.gc].join("\t")
  #   end
  # 
  # @example Parsing a fasta file (with truthy value param)
  #   FastaFile.open('reads.fna').each_record(1) do |header, sequence|
  #     # header => 'sequence_1'
  #     # sequence => ['AACTG', 'AGTCGT', ... ]
  #   end
  # 
  # @yield The header and sequence for each record in the fasta
  #   file to the block
  #
  # @yieldparam header [String] The header of the fasta record without
  #   the leading '>'
  #
  # @yieldparam sequence [Sequence, Array<Sequence>] The sequence of the
  #   fasta record. If `separate_lines` is falsy (the default
  #   behavior), will be Sequence, but if truthy will be
  #   Array<String>.
  def each_record(separate_lines=nil)
    begin
      f = Zlib::GzipReader.open(self)
    rescue Zlib::GzipFile::Error => e
      f = self
    end      

    if separate_lines
      f.each("\n>") do |line|
        header, sequence = parse_line_separately(line)
        yield(header.strip, sequence)
      end
    else
      f.each("\n>") do |line| 
        header, sequence = parse_line(line)
        yield(header.strip, Sequence.new(sequence))
      end
    end

    f.close if f.instance_of?(Zlib::GzipReader)
    return f
  end

  private
  def parse_line(line)
    line.chomp.split("\n", 2).map { |s| s.gsub(/\n|>/, '') }
  end

  def parse_line_separately(line)
    header, sequence = 
      line.chomp.split("\n", 2).map { |s| s.gsub(/>/, '') }
    sequences = sequence.split("\n")
      .reject { |s| s.empty? }
      .map { |s| Sequence.new(s) }

    [header, sequences]
  end
end
