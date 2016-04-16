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

# Provides simple interface for parsing four-line-per-record fastq
# format files. Gzipped files are no problem.
class FastqFile < File

  # Returns the records in the fastq file as a hash map with the
  # headers as keys pointing to a hash map like so
  # { "seq1" => { head: "seq1", seq: "ACTG", desc: "", qual: "II3*"} }
  #
  # @example Read a fastQ into a hash table.
  #   seqs = FastqFile.open('reads.fq.gz').to_hash
  #
  # @return [Hash] A hash with headers as keys, and a hash map as the
  #   value with keys :head, :seq, :desc, :qual, for header, sequence,
  #   description, and quality.
  def to_hash
    hash = {}
    self.each_record do |head, seq, desc, qual|
      hash[head] = { head: head, seq: seq, desc: desc, qual: qual }
    end

    hash
  end

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
        header = line[1..-1]
      when 1
        sequence = Sequence.new(line)
      when 2
        description = line[1..-1]
      when 3
        quality = Quality.new(line)
        yield(header, sequence, description, quality)
      end

      count += 1
    end

    f.close if f.instance_of?(Zlib::GzipReader)
    return f
  end

  # Fast version of #each_record
  #
  # @note If the fastQ file has spaces in the sequence, they will be
  #   retained. If this is a problem, use #each_record instead.
  #
  # @example Parsing a fastq file
  #   FastqFile.open('reads.fq').each_record_fast do |head, seq, desc, qual|
  #     # do some fun stuff here!
  #   end
  # @example Use the same syntax for gzipped files!
  #   FastqFile.open('reads.fq.gz').each_record_fast do |head, seq, desc, qual|
  #     # do some fun stuff here!
  #   end
  #
  # @yield The header, sequence, description and quality string for
  #   each record in the fastq file to the block
  #
  # @yieldparam header [String] The header of the fastq record without
  #   the leading '@'
  # @yieldparam sequence [String] The sequence of the fastq record
  # @yieldparam description [String] The description line of the fastq
  #   record without the leading '+'
  # @yieldparam quality_string [String] The quality string of the
  #   fastq record
  def each_record_fast
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
        header = line[1..-1]
      when 1
        sequence = line
      when 2
        description = line[1..-1]
      when 3
        quality = line
        yield(header, sequence, description, quality)
      end

      count += 1
    end

    f.close if f.instance_of?(Zlib::GzipReader)
    return f
  end
end
