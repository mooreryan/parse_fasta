# parse_fasta #

[![Gem Version](https://badge.fury.io/rb/parse_fasta.svg)](http://badge.fury.io/rb/parse_fasta) [![Build Status](https://travis-ci.org/mooreryan/parse_fasta.svg?branch=master)](https://travis-ci.org/mooreryan/parse_fasta) [![Coverage Status](https://coveralls.io/repos/mooreryan/parse_fasta/badge.svg)](https://coveralls.io/r/mooreryan/parse_fasta)

So you want to parse a fasta file...

## Installation ##

Add this line to your application's Gemfile:

    gem 'parse_fasta'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install parse_fasta

## Overview ##

Provides nice, programmatic access to fasta and fastq files, as well
as providing Sequence and Quality helper classes. It's more
lightweight than BioRuby. And more fun! ;)

## Documentation ##

Checkout
[parse_fasta docs](http://rubydoc.info/gems/parse_fasta)
for the full api documentation.

## Usage ##

Some examples...

A little script to print header and length of each record.

	require 'parse_fasta'

	FastaFile.open(ARGV[0]).each_record do |header, sequence|
	  puts [header, sequence.length].join("\t")
	end

And here, a script to calculate GC content:

	FastaFile.open(ARGV[0]).each_record do |header, sequence|
	  puts [header, sequence.gc].join("\t")
	end

Now we can parse fastq files as well!

	FastqFile.open(ARGV[0]).each_record do |head, seq, desc, qual|
	  puts [header, qual.qual_scores.join(',')].join("\t")
	end

What if you don't care if the input is a fastA or a fastQ? No problem!

	SeqFile.open(ARGV[0]).each_record do |head, seq|
	  puts [header, seq].join "\t"
	end

Read fasta file into a hash.

    seqs = FastaFile.open(ARGV[0]).to_hash

## Versions ##

### 1.9.0 ###

Added "fast" versions of `each_record` methods
(`each_record_fast`). Basically, they return sequences and quality
strings as Ruby `Sring` objects instead of aa `Sequence` or `Quality`
objects. Also, if the sequence or quality string has spaces, they will
be retained. If this is a problem, use the original `each_record`
methods.

### 1.8.2 ###

Speed up `FastqFile#each_record`.

### 1.8.1 ###

An error will be raised if a fasta file has a `>` in the
sequence. Sometimes files are not terminated with a newline
character. If this is the case, then catting two fasta files will
smush the first header of the second file right in with the last
sequence of the first file. This is bad, raise an error! ;)

Example

    >seq1
    ACTG>seq2
    ACTG
    >seq3
    ACTG

This will raise `ParseFasta::SequenceFormatError`.

Also, headers with lots of `>` within are fine now.

### 1.8 ###

Add `Sequence#rev_comp`. It can handle IUPAC characters. Since
`parse_fasta` doesn't check whether the seq is AA or NA, if called on
an amino acid string, things will get weird as it will complement the
IUPAC characters in the AA string and leave others.

### 1.7.2 ###

Strip spaces (not all whitespace) from `Sequence` and `Quality` strings.

Some alignment fastas have spaces for easier reading. Strip these
out. For consistency, also strips spaces from `Quality` strings. If
there are spaces that don't match in the quality and sequence in a
fastQ file, then things will get messed up in the FastQ file. FastQ
shouldn't have spaces though.

### 1.7 ###

Add `SeqFile#to_hash`, `FastaFile#to_hash` and `FastqFile#to_hash`.

### 1.6.2 ###

`FastaFile::open` now raises a `ParseFasta::DataFormatError` when passed files
that don't begin with a `>`.

### 1.6.1 ###

Better internal handling of empty sequences -- instead of raising
errors, pass empty sequences.

### 1.6 ###

Added `SeqFile` class, which accepts either fastA or fastQ files. It
uses FastaFile and FastqFile internally. You can use this class if you
want your scripts to accept either fastA or fastQ files.

If you need the description and quality string, you should use
FastqFile instead.

### 1.5 ###

Now accepts gzipped files. Huzzah!

### 1.4 ###

Added methods:

    Sequence.base_counts
	Sequence.base_frequencies

### 1.3 ###

Add additional functionality to `each_record` method.

#### Info ####

I often like to use the fasta format for other things like so

	>fruits
	pineapple
	pear
	peach
	>veggies
	peppers
	parsnip
	peas

rather than having this in a two column file like this

	fruit,pineapple
	fruit,pear
	fruit,peach
	veggie,peppers
	veggie,parsnip
	veggie,peas

So I added functionality to `each_record` to keep each line a record
separate in an array. Here's an example using the above file.

    info = []
	FastaFile.open(f, 'r').each_record(1) do |header, lines|
	  info << [header, lines]
	end

Then info will contain the following arrays

	['fruits', ['pineapple', 'pear', 'peach']],
	['veggies', ['peppers', 'parsnip', 'peas']]

### 1.2 ###

Added `mean_qual` method to the `Quality` class.

### 1.1.2 ###

Dropped Ruby requirement to 1.9.3

(Note, if you want to build the docs with yard and you're using
Ruby 1.9.3, you may have to install the redcarpet gem.)

### 1.1 ###

Added: Fastq and Quality classes

### 1.0 ###

Added: Fasta and Sequence classes

Removed: File monkey patch

### 0.0.5 ###

Last version with File monkey patch.

## Benchmark ##

**NOTE**: These benchmarks are against an older version of
  `parse_fasta`.

Some quick and dirty benchmarks against `BioRuby`.

### FastaFile#each_record ###

Calculating sequence length length for each fasta record with both the
`each_record` method from this gem and using the `FastaFormat` class
from BioRuby. You can see the test script in `benchmark.rb`.

The test file contained 2,009,897 illumina reads and the file size
was 1.1 gigabytes. Here are the results from Ruby's `Benchmark` class:

                      user     system      total        real
    parse_fasta  64.530000   1.740000  66.270000 ( 67.081502)
    bioruby     116.250000   2.260000 118.510000 (120.223710)

Hot dog! It's faster :)

### FastqFile#each_record ###

The same sequence length test as above, but this time with a fastq
file containing 4,000,000 illumina reads.

                        user     system      total        real
    this_fastq     62.610000   1.660000  64.270000 ( 64.389408)
    bioruby_fastq 165.500000   2.100000 167.600000 (167.969636)

### Sequence#gc ###

The test is done on random strings matcing `/[AaCcTtGgUu]/`. `this_gc`
is `Sequence.new(str).gc`, and `bioruby_gc` is
`Bio::Sequence::NA.new(str).gc_content`.

To see how the methods scales, the test 1 string was 2,000,000 bases,
test 2 was 4,000,000 and test 3 was 8,000,000 bases.

                       user     system      total        real
    this_gc 1      0.030000   0.000000   0.030000 (  0.029145)
    bioruby_gc 1   2.030000   0.010000   2.040000 (  2.157512)

	this_gc 2      0.060000   0.000000   0.060000 (  0.059408)
    bioruby_gc 2   4.060000   0.020000   4.080000 (  4.334159)

	this_gc 3      0.120000   0.000000   0.120000 (  0.185434)
    bioruby_gc 3   8.060000   0.020000   8.080000 (  8.659071)

Nice!

Troll: "When will you find the GC of an 8,000,000 base sequence?"

Me: "Step off, troll!"

## Notes ##

Only the `SeqFile` class actually checks to make sure that you passed
in a "proper" fastA or fastQ file, so watch out.
