#!/usr/bin/env ruby

# Copyright 2014 Ryan Moore
# Contact: moorer@udel.edu

# This file is part of parse_fasta.

# parse_fasta is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# parse_fasta is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with parse_fasta.  If not, see <http://www.gnu.org/licenses/>.

require 'parse_fasta'
require 'bio'
require 'benchmark'

def parse_fasta fname
  File.open(fname, 'r').each_record do |header, sequence|
    [header, sequence.length].join("\t")
  end
end

def bioruby fname
  Bio::FastaFormat.open(fname).each do |entry|
    [entry.definition, entry.seq.length].join("\t")
  end
end

Benchmark.bmbm do |x|
  x.report('parse_fasta') { parse_fasta(ARGV.first) }
  x.report('bioruby')     { bioruby(ARGV.first) }
end
