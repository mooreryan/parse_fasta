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

  # Use it like IO::open
  #
  # @param fname [String] the name of the file to open
  #
  # @return [FastaFile] a FastaFile
  def self.open(fname, *args)
    begin
      handle = Zlib::GzipReader.open(fname)
    rescue Zlib::GzipFile::Error => e
      handle = File.open(fname)
    end

    unless handle.each_char.peek[0] == '>'
      raise ParseFasta::DataFormatError
    end

    handle.close

    super
  end

  # Returns the records in the fasta file as a hash map with the
  # headers as keys and the Sequences as values.
  #
  # @example Read a fastA into a hash table.
  #   seqs = FastaFile.open('reads.fa').to_hash
  #
  # @return [Hash] A hash with headers as keys, sequences as the
  #   values (Sequence objects)
  #
  # @raise [ParseFasta::SequenceFormatError] if sequence has a '>'
  def to_hash
    hash = {}
    self.each_record do |head, seq|
      hash[head] = seq
    end

    hash
  end

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
  #
  # @raise [ParseFasta::SequenceFormatError] if sequence has a '>'
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

      # f.each_with_index(">") do |line, idx|
      #   if idx.zero?
      #     if line != ">"
      #       raise ParseFasta::DataFormatError
      #     end
      #   else
      #     header, sequence = parse_line_separately(line)
      #     yield(header.strip, sequence)
      #   end
      # end
    else
      f.each("\n>") do |line|
        header, sequence = parse_line(line)
        yield(header.strip, Sequence.new(sequence || ""))
      end

      # f.each_with_index(sep=/^>/) do |line, idx|
      #   if idx.zero?
      #     if line != ">"
      #       raise ParseFasta::DataFormatError
      #     end
      #   else
      #     header, sequence = parse_line(line)
      #     yield(header.strip, Sequence.new(sequence || ""))
      #   end
      # end
    end

    f.close if f.instance_of?(Zlib::GzipReader)
    return f
  end

  # Fast version of #each_record
  #
  # Yields the sequence as a String, not Sequence. No separate lines
  # option.
  #
  # @note If the fastA file has spaces in the sequence, they will be
  #   retained. If this is a problem, use #each_record instead.
  #
  # @yield The header and sequence for each record in the fasta
  #   file to the block
  #
  # @yieldparam header [String] The header of the fasta record without
  #   the leading '>'
  #
  # @yieldparam sequence [String] The sequence of the fasta record
  #
  # @raise [ParseFasta::SequenceFormatError] if sequence has a '>'
  def each_record_fast
    begin
      f = Zlib::GzipReader.open(self)
    rescue Zlib::GzipFile::Error => e
      f = self
    end

    f.each("\n>") do |line|
      header, sequence = parse_line(line)

      raise ParseFasta::SequenceFormatError if sequence.include? ">"

      yield(header.strip, sequence)
    end

    f.close if f.instance_of?(Zlib::GzipReader)
    return f
  end

  private

  def parse_line(line)
    line.split("\n", 2).map { |s| s.gsub(/\n|^>|>$/, '') }
  end

  def parse_line_separately(line)
    header, sequence =
      line.split("\n", 2).map { |s| s.gsub(/^>|>$/, '') }

    if sequence.nil?
      sequences = []
    else
      sequences = sequence.split("\n")
        .reject { |s| s.empty? }
        .map { |s| Sequence.new(s) }
    end

    [header, sequences]
  end
end
