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
  class Record

    # @!attribute header
    #   @return [String] the full header of the record without the '>'
    #     or '@'
    # @!attribute id
    #   @return [String] the "id" i.e., the first token when split by
    #     whitespace
    # @!attribute seq
    #   @return [String] the sequence of the record
    # @!attribute desc
    #   @return [String or Nil] if the record is from a fastA file, it
    #     is nil; else, the description line of the fastQ record
    # @!attribute qual
    #   @return [String or Nil] if the record is from a fastA file, it
    #     is nil; else, the quality string of the fastQ record
    attr_accessor :header, :id, :seq, :desc, :qual

    # The constructor takes keyword args.
    #
    # @example Init a new Record object for a fastA record
    #   Record.new header: "apple", seq: "actg"
    # @example Init a new Record object for a fastA record without checking for '>' in the sequence.
    #   Record.new header: "apple", seq: "pie>good", check_fasta_seq: false
    # @example Init a new Record object for a fastQ record
    #   Record.new header: "apple", seq: "actd", desc: "", qual: "IIII"
    #
    # @param header [String] the header of the record
    # @param seq [String] the sequence of the record
    # @param desc [String] the description line of a fastQ record
    # @param qual [String] the quality string of a fastQ record
    # @param check_fasta_seq [Bool] Pass false if you don't want to
    #   check for '>' characters in the sequence. Defaults to true,
    #   which checks for '>' in the sequence and raises an error.
    #
    # @raise [ParseFasta::Error::SequenceFormatError] if a fastA
    #   sequence has a '>' character in it, and :check_fasta_seq is
    #   NOT set to false.
    #
    # @todo This is destructive with respect to the input seq
    #   arg. Does it need to be?
    def initialize args = {}
      @header = args.fetch :header
      @id = @header.split(" ")[0]

      @desc = args.fetch :desc, nil
      @qual = args.fetch :qual, nil

      @qual.tr!(" \t\n\r", "") if @qual

      seq = args.fetch(:seq)
      seq.tr!(" \t\n\r", "")

      do_check_fasta_seq = args.fetch :check_fasta_seq, true

      if fastq? || (!fastq? && !do_check_fasta_seq)
        @seq = seq
      else
        @seq = check_fasta_seq(seq)
      end
    end

    # Compare attrs of this rec with another
    #
    # @param rec [Record] a Record object to compare with
    #
    # @return [Bool] true or false
    def == rec
      self.header == rec.header && self.seq == rec.seq &&
          self.desc == rec.desc && self.qual == rec.qual
    end

    # Return a fastA or fastQ record ready to print.
    #
    # If the Record is fastQ like then it returns a fastQ record
    # string. If the record is fastA like, then it returns a fastA
    # record string.
    #
    # @return [String] a printable sequence record
    #
    # @example When the record is fastA like
    #   rec = Record.new header: "Apple", seq: "ACTG"
    #   rec.to_s #=> ">Apple\nACTG"
    #
    # @example When the record is fastQ like
    #   rec = Record.new header: "Apple", seq: "ACTG", desc: "Hi", qual: "IIII"
    #   rec.to_s #=> "@Apple\nACTG\n+Hi\nIIII"
    def to_s
      if fastq?
        to_fastq
      else
        to_fasta
      end
    end

    # Returns a fastA record ready to print.
    #
    # If the record is fastQ like, the desc and qual are dropped.
    #
    # @return [String] a printable fastA sequence record
    #
    # @example When the record is fastA like
    #   rec = Record.new header: "Apple", seq: "ACTG"
    #   rec.to_fasta #=> ">Apple\nACTG"
    #
    # @example When the record is fastQ like
    #   rec = Record.new header: "Apple", seq: "ACTG", desc: "Hi", qual: "IIII"
    #   rec.to_fasta #=> ">Apple\nACTG"
    def to_fasta
      ">#{header}\n#{seq}"
    end

    # Returns a fastA record ready to print.
    #
    # If the record is fastA like, the desc and qual can be specified.
    #
    # @return [String] a printable fastQ sequence record
    #
    # @example When the record is fastA like, no args
    #   rec = Record.new header: "Apple", seq: "ACTG"
    #   rec.to_fastq #=> "@Apple\nACTG\n+\nIIII"
    #
    # @example When the record is fastA like, desc and qual specified
    #   rec = Record.new header: "Apple", seq: "ACTG"
    #   rec.to_fastq decs: "Hi", qual: "A" #=> "@Apple\nACTG\n+Hi\nAAAA"
    #
    # @example When the record is fastA like, can specify fancy qual strings
    #   rec = Record.new header: "Apple", seq: "ACTGACTG"
    #   rec.to_fastq decs: "Hi", qual: "!a2" #=> "@Apple\nACTG\n+Hi\n!a2!a2!a"
    #
    # @example When the record is fastQ like
    #   rec = Record.new header: "Apple", seq: "ACTG", desc: "Hi", qual: "IIII"
    #   rec.to_fastq #=> ">Apple\nACTG"
    #
    # @raise [ParseFasta::Error::ArgumentError] if qual is ""
    def to_fastq opts = {}
      if fastq?
        "@#{@header}\n#{@seq}\n+#{@desc}\n#{qual}"
      else
        qual = opts.fetch :qual, "I"
        check_qual qual

        desc  = opts.fetch :desc, ""

        qual_str = make_qual_str qual

        "@#{@header}\n#{@seq}\n+#{desc}\n#{qual_str}"
      end
    end

    # Returns true if record is a fastQ record.
    #
    # This method returns true if the fastq instance method is set.
    #
    # @return [Bool] true if record is fastQ, false if it is fastA
    def fastq?
      true if @qual
    end

    private

    def check_fasta_seq seq
      if seq.include? ">"
        raise ParseFasta::Error::SequenceFormatError,
              "A sequence contained a '>' character " +
                  "(the fastA file record separator)"
      else
        seq
      end
    end

    def make_qual_str qual
      (qual * (@seq.length / qual.length.to_f).ceil)[0, @seq.length]
    end

    def check_qual qual
      if qual.length.zero?
        raise ParseFasta::Error::ArgumentError,
              ":qual was '#{qual.inspect}', but it can't be empty"
      end
    end
  end
end
