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

I wanted a simple, fast way to parse fasta files so I wouldn't have to
keep writing annoying boilerplate fasta parsing code everytime I go to
do something with one. I will probably add more, but likely only tasks
that I find myself doing over and over.

## Documentation ##

Checkout `https://rubygems.org/gems/parse_fasta` to see the docs.

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

An example that lists the length for each sequence. (Won't work in
version 1.0.0)

    require 'parse_fasta'

	File.open(ARGV.first, 'r').each_record do |header, sequence|
	  puts [header, sequence.length].join("\t")
	end

## Benchmark ##

Take these with a grain of salt since `BioRuby` is a heavy weight
module with lots of features and error checking, whereas `parse_fasta`
is meant to be lightweight and easy to use for my own coding.

### FastaFile#each_record ###

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

### Sequence#gc ###

I played around with a few different implementations for the `#gc`
method and found this one to be the fastest.

The test is done one random strings mating `/[AaCcTtGgUu]/`. `this_gc`
is `Sequence.new(str).gc`, and `bioruby_gc` is
`Bio::Sequence::NA.new(str).gc_content`.

To see how the methods scale, the test 1 string was 2,000,000 bases,
test 2 was 4,000,000 and test 3 was 8,000,000 bases.

                       user     system      total        real
    this_gc 1      0.030000   0.000000   0.030000 (  0.029145)
    bioruby_gc 1   2.030000   0.010000   2.040000 (  2.157512)

	this_gc 2      0.060000   0.000000   0.060000 (  0.059408)
    bioruby_gc 2   4.060000   0.020000   4.080000 (  4.334159)

	this_gc 3      0.120000   0.000000   0.120000 (  0.185434)
    bioruby_gc 3   8.060000   0.020000   8.080000 (  8.659071)

Nice!

## Notes ##

Currently in doesn't check whether your file is actually a fasta file
or anything, so watch out.
