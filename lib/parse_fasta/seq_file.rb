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

# Provides a class that will parse either fastA or fastQ files,
# depending on what the user provides. Handles, gzipped files.
class SeqFile < File

  # Returns the records in the sequence file as a hash map with the
  # headers as keys and the Sequences as values. For a fastq file,
  # acts the same as `FastaFile#to_hash`
  #
  # @example Read a fastA into a hash table.
  #   seqs = SeqFile.open('reads.fa').to_hash
  #
  # @return [Hash] A hash with headers as keys, sequences as the
  #   values (Sequence objects)
  #
  # @raise [ParseFasta::SequenceFormatError] if sequence has a '>',
  #   and file is a fastA file
  def to_hash
    first_char = get_first_char(self)

    if first_char == '>'
      FastaFile.open(self).to_hash
    elsif first_char == '@'
      FastqFile.open(self).to_hash
    else
      raise ArgumentError, "Input does not look like FASTA or FASTQ"
    end
  end

  # Analagous to IO#each_line, #each_record will go through a fastA or
  # fastQ file record by record.
  #
  # This #each_record is used in a similar fashion as
  # FastaFile#each_record except that it yields the header and the
  # sequence regardless of whether the input is a fastA file or a
  # fastQ file.
  #
  # If the input is a fastQ file, this method will yield the header
  # and the sequence and ignore the description and the quality
  # string. This SeqFile class should only be used if your program
  # needs to work on either fastA or fastQ files, thus it ignores the
  # quality string and description and treats either file type as if
  # it were a fastA file.
  #
  # If you need the description or quality, you should use
  # FastqFile#each_record instead.
  #
  # @example Parse a gzipped fastA file
  #   SeqFile.open('reads.fa.gz').each_record do |head, seq|
  #     puts [head, seq.length].join "\t"
  #   end
  #
  # @example Parse an uncompressed fastQ file
  #   SeqFile.open('reads.fq.gz').each_record do |head, seq|
  #     puts [head, seq.length].join "\t"
  #   end
  #
  # @yieldparam header [String] The header of the record without the
  #   leading '>' or '@'
  #
  # @yieldparam sequence [Sequence] The sequence of the record.
  #
  # @raise [ParseFasta::SequenceFormatError] if sequence has a '>',
  #   and file is a fastA file
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
