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

I wanted a simple, fast way to parse fasta and fastq files so I
wouldn't have to keep writing annoying boilerplate parsing code
everytime I go to do something with a fasta or fastq file. I will
probably add more, but likely only tasks that I find myself doing over
and over.

## Documentation ##

Checkout
[parse_fasta docs](http://rubydoc.info/gems/parse_fasta/1.1.0/frames)
to see the full documentation.

## Usage ##

A little script to print header and length of each record.

	require 'parse_fasta'

	FastaFile.open(ARGV.first, 'r').each_record do |header, sequence|
	  puts [header, sequence.length].join("\t")
	end

And here, a script to calculate GC content:

	FastaFile.open(ARGV.first, 'r').each_record do |header, sequence|
	  puts [header, sequence.gc].join("\t")
	end

Now we can parse fastq files as well!

	FastqFile.open(ARGV.first, 'r').each_record do |head, seq, desc, qual|
	  puts [header, seq, desc, qual.qual_scores.join(',')].join("\t")
	end

## Versions ##

### 1.1.2 ###

Dropped Ruby requirement to 1.9.3

### 1.1.0 ###

Added: Fastq and Quality classes

### 1.0.0 ###

Added: Fasta and Sequence classes

Removed: File monkey patch

### 0.0.5 ###

Last version with File monkey patch.

## Benchmark ##

Take these with a grain of salt since `BioRuby` is a big module
module with lots of features and error checking, whereas `parse_fasta`
is meant to be lightweight and easy to use for my own research.

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

### FastqFile#each_record ###

The same sequence length test as above, but this time with a fastq
file containing 4,000,000 illumina reads.

                        user     system      total        real
    this_fastq     62.610000   1.660000  64.270000 ( 64.389408)
    bioruby_fastq 165.500000   2.100000 167.600000 (167.969636)

### Sequence#gc ###

I played around with a few different implementations for the `#gc`
method and found this one to be the fastest.

The test is done on random strings mating `/[AaCcTtGgUu]/`. `this_gc`
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
