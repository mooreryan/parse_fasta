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
    # @!attribute seq
    #   @return [String] the sequence of the record
    # @!attribute desc
    #   @return [String or Nil] if the record is from a fastA file, it
    #     is nil; else, the description line of the fastQ record
    # @!attribute qual
    #   @return [String or Nil] if the record is from a fastA file, it
    #     is nil; else, the quality string of the fastQ record
    attr_accessor :header, :seq, :desc, :qual

    # The constructor takes keyword args.
    #
    # @example Init a new Record object for a fastA record
    #   Record.new header: "apple", seq: "actg"
    # @example Init a new Record object for a fastQ record
    #   Record.new header: "apple", seq: "actd", desc: "", qual: "IIII"
    #
    # @param header [String] the header of the record
    # @param seq [String] the sequence of the record
    # @param desc [String] the description line of a fastQ record
    # @param qual [String] the quality string of a fastQ record
    #
    # @raise [SequenceFormatError] if a fastA sequence has a '>'
    #   character in it
    def initialize args = {}
      @header = args.fetch :header

      @desc = args.fetch :desc, nil
      @qual = args.fetch :qual, nil

      @qual.gsub!(/\s+/, "") if @qual

      seq = args.fetch(:seq).gsub(/\s+/, "")

      if @qual # is fastQ
        @seq = seq
      else # is fastA
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

    private

    def check_fasta_seq seq
      if seq.match ">"
        raise ParseFasta::Error::SequenceFormatError,
              "A sequence contained a '>' character " +
                  "(the fastA file record separator)"
      else
        seq
      end
    end
  end
end
