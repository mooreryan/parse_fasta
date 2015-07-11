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

require 'coveralls'
Coveralls.wear!

require 'parse_fasta'

module Helpers

  RECORDS = [["empty seq at beginning", ""],
             ["seq1 is fun", "AACTGGNNN"],
             ["seq2", "AATCCTGNNN"],
             ["empty seq 1", ""],
             ["empty seq 2", ""],
             ["seq3", "yyyyyyyyyyyyyyyNNN"],
             ["empty seq at end", ""]]

  RECORDS_MAP = {
    "empty seq at beginning" => "",
    "seq1 is fun" => "AACTGGNNN",
    "seq2" => "AATCCTGNNN",
    "empty seq 1" => "",
    "empty seq 2" => "",
    "seq3" => "yyyyyyyyyyyyyyyNNN",
    "empty seq at end" => ""
  }


  TRUTHY_RECORDS = [["empty seq at beginning", []],
                    ["seq1 is fun", ["AACTGGNNN"]],
                    ["seq2", ["AAT", "CCTGNNN"]],
                    ["empty seq 1", []],
                    ["empty seq 2", []],
                    ["seq3", ["yyyyyyyyyy", "yyyyy", "NNN"]],
                    ["empty seq at end", []]]

end
