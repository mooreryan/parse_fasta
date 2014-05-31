#!/usr/bin/env ruby

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
