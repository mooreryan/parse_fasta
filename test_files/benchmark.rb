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

def this_parse_fasta fname
  FastaFile.open(fname, 'r').each_record do |header, sequence|
    [header, sequence.length].join("\t")
  end
end

def bioruby_parse_fasta fname
  Bio::FastaFormat.open(fname).each do |entry|
    [entry.definition, entry.seq.length].join("\t")
  end
end

# Benchmark.bmbm do |x|
#   x.report('parse_fasta') { this_parse_fasta(ARGV.first) }
#   x.report('bioruby')     { bioruby_parse_fasta(ARGV.first) }
# end

####

def this_gc(str)
  Sequence.new(str).gc
end

def bioruby_gc(str)
  Bio::Sequence::NA.new(str).gc_content
end

# make a random sequence of given length
def make_seq(num)
  num.times.reduce('') { |str, n| str << %w[A a C c T t G g N n].sample }
end

# s1 = make_seq(2000000)
# s2 = make_seq(4000000)
# s3 = make_seq(8000000)

# Benchmark.bmbm do |x|
#   x.report('this_gc 1') { this_gc(s1) }
#   x.report('bioruby_gc 1') { bioruby_gc(s1) }

#   x.report('this_gc 2') { this_gc(s2) }
#   x.report('bioruby_gc 2') { bioruby_gc(s2) }

#   x.report('this_gc 3') { this_gc(s3) }
#   x.report('bioruby_gc 3') { bioruby_gc(s3) }
# end

fastq = ARGV.first

def bioruby_fastq(fastq)
  Bio::FlatFile.open(Bio::Fastq, fastq) do |fq| 
    fq.each do |entry| 
      [entry.definition, entry.seq.length].join("\t")
    end
  end
end

def this_fastq(fastq)
  FastqFile.open(fastq).each_record do |head, seq, desc, qual|
    [head, seq.length].join("\t")
  end
end

# file is 4 million illumina reads (16,000,000 lines) 1.4gb
Benchmark.bmbm do |x|
  x.report('this_fastq') { this_fastq(ARGV.first) }
  x.report('bioruby_fastq') { bioruby_fastq(ARGV.first) }
end
