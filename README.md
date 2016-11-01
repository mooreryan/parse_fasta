# ParseFasta #

[![Gem Version](https://badge.fury.io/rb/parse_fasta.svg)](http://badge.fury.io/rb/parse_fasta) [![Build Status](https://travis-ci.org/mooreryan/parse_fasta.svg?branch=master)](https://travis-ci.org/mooreryan/parse_fasta) [![Coverage Status](https://coveralls.io/repos/mooreryan/parse_fasta/badge.svg)](https://coveralls.io/r/mooreryan/parse_fasta)

So you want to parse a fasta file...

## Installation ##

Add this line to your application's Gemfile:

```ruby
gem 'parse_fasta'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install parse_fasta

## Overview ##

Provides nice, programmatic access to fasta and fastq files. It's faster and more lightweight than BioRuby. And more fun!

## Documentation ##

Checkout
[parse_fasta docs](http://rubydoc.info/gems/parse_fasta)
for the full api documentation.

## Usage ##

Here are some examples of using ParseFasta. Don't forget to `require "parse_fasta"` at the top of your program!

Print header and length of each record.

```ruby
ParseFasta::SeqFile.open(ARGV[0]).each_record do |rec|
  puts [rec.header, rec.seq.length].join "\t"
end
```

You can parse fastQ files in exatcly the same way.

```ruby
ParseFasta::SeqFile.open(ARGV[0]).each_record do |rec|
  printf "Header: %s, Sequence: %s, Description: %s, Quality: %s\n",
	     rec.header,
	     rec.seq,
	     rec.desc,
	     rec.qual
end
```

The `Record#desc` and `Record#qual` will be `nil` if the file you are parsing is a fastA file.

```ruby
ParseFasta::SeqFile.open(ARGV[0]).each_record do |rec|
  if rec.qual
    # it's a fastQ record
  else
    # it's a fastA record
  end
end
```

You can also check this with `Record#fastq?`

```ruby
ParseFasta::SeqFile.open(ARGV[0]).each_record do |rec|
  if rec.fastq?
    # it's a fastQ record
  else
    # it's a fastA record
  end
end
```

And there is a nice `#to_s` method, that does what it should whether the record is fastA or fastQ like. Check out the docs for info on the fancy `#to_fasta` and `#to_fastq` methods!

```ruby
ParseFasta::SeqFile.open(ARGV[0]).each_record do |rec|
  puts rec.to_s
end
```

But of course, since it is a `#to_s` override...you don't even have to call it directly!

```ruby
ParseFasta::SeqFile.open(ARGV[0]).each_record do |rec|
  puts rec
end
```
