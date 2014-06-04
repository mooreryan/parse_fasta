# parse_fasta #

So you want to parse a fasta file...

## Installation ##

Add this line to your application's Gemfile:

    gem 'parse_fasta'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install parse_fasta

## Overview ##

Provides the method `#each_record` for the `File` class.

	each_record { |header, sequence| block }

The whole file is not loaded into memory, so have no fear of giant
fasta files!

## Usage ##

### Version 1.0.0 (current) ###

The monkey patch of the `File` class is no more! Here is the new print
length example:

	require 'parse_fasta'

	FastaFile.open(ARGV.first, 'r').each_record do |header, sequence|
	  puts [header, sequence.length].join("\t")
	end

And here, a script to calculate GC content:

	require 'parse_fasta'

	FastaFile.open(ARGV.first, 'r').each_record do |header, sequence|
	  puts [header, sequence.gc].join("\t")
	end

### Version 0.0.5 (old) ###

An example that lists the length for each sequence. (Won't work in version 1.0.0)

    require 'parse_fasta'

	File.open(ARGV.first, 'r').each_record do |header, sequence|
	  puts [header, sequence.length].join("\t")
	end

## Benchmark ##

Just for fun, I wanted to compare the execution time to that of
BioRuby. I calculated sequence length for each fasta record with both
the `each_record` method from this gem and using the `FastaFormat`
class from BioRuby. You can see the test script in `benchmark.rb`.

The test file contained 2,009,897 illumina reads and the file size
was 1.1 gigabytes. Here are the results from Ruby's `Benchmark` class:

                      user     system      total        real
    parse_fasta  64.530000   1.740000  66.270000 ( 67.081502)
    bioruby     116.250000   2.260000 118.510000 (120.223710)

I just wanted a nice, clean way to parse fasta files, but being nearly
twice as fasta as BioRuby doesn't hurt either!

## Notes ##

Currently in doesn't check whether your file is actually a fasta file
or anything, so watch out.
