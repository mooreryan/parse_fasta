# Copyright 2014 Ryan Moore
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

# Provides simple interface for parsing fasta format files.
class FastaFile < File

  # Analagous to File#each_line, #each_record is used to go through a
  # fasta file record by record.
  #
  # @example Parsing a fasta file
  #   FastaFile.open('reads.fna', 'r').each_record do |header, sequence|
  #     puts [header, sequence.gc].join("\t")
  #   end
  # 
  # @yield The header and sequence for each record in the fasta
  #   file to the block
  # @yieldparam header [String] The header of the fasta record without
  #   the leading '>'
  # @yieldparam sequence [Sequence] The sequence of the fasta record
  def each_record
    self.each("\n>") do |line|
      header, sequence = parse_line(line)
      yield(header.strip, Sequence.new(sequence))
    end
  end

  private
  def parse_line(line)
    line.chomp.split("\n", 2).map { |s| s.gsub(/\n|>/, '') }
  end
end
