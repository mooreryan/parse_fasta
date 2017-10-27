## Versions ##

### 2.3.0 ###

Allow parsing of fastA files with `>` characters in the sequence with the `check_fasta_seq: false` option.

### 2.2.0 ###

Add `id` attribute to `Record`.

### 2.1.1 ###

Speed up `Record.new`

### 2.1.0 ###

Add `#to_s`, `#to_fasta`, and `#to_fastq` to `Record`.

### 2.0.0 ###

A weird feature of `Zlib::GzipReader` made it so that if a gzipped file was created like this.

```bash
gzip -c a.fa > z.fa.gz
gzip -c b.fa >> z.fa.gz
```

Then the gzip reader would only read the lines from `a.fa` without some fiddling around. Since this was a pretty low level thing, I just decided to make a bunch of under the hood changes that I've been meaning to get to.

#### Other things

- Everything is namespaced under `ParseFasta` module
- Removed `FastaFile` and `FastqFile` classes, `SeqFile` only remains
- Removed `Sequence` and `Quality` classes. These might get put back in at some point, but I almost never used them anyway
- `SeqFile#each_record` yields a `Record` object so you can use the same code to parse fastA and fastQ files
- Other stuff that I'm forgetting!


### 1.9.2 ###

Speed up fastA `each_record` and `each_record_fast`.

### 1.9.1 ###

Speed up fastQ `each_record` and `each_record_fast`. Courtesy of
[Matthew Ralston](https://github.com/MatthewRalston).

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
