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

# Provide some methods for dealing with common tasks regarding
# nucleotide sequences.
class Sequence < String

  # Strips whitespace from the str argument before calling super
  #
  # @return [Sequence] A Sequence string
  #
  # @example Removes whitespace
  #   Sequence.new "AA CC TT" #=> "AACCTT"
  def initialize(str)
    super(str.gsub(/ +/, ""))
  end

  # Calculates GC content
  #
  # Calculates GC content by dividing count of G + C divided by count
  # of G + C + T + A + U. If there are both T's and U's in the
  # Sequence, things will get weird, but then again, that wouldn't
  # happen, now would it! Ambiguous bases are ignored similar to
  # BioRuby.
  #
  # @example Get GC of a Sequence
  #   Sequence.new('ACTg').gc #=> 0.5
  # @example Using with FastaFile#each_record
  #   FastaFile.open('reads.fna', 'r').each_record do |header, sequence|
  #     puts [header, sequence.gc].join("\t")
  #   end
  #
  # @return [0] if the Sequence is empty or there are no A, C, T, G or U
  #   present
  # @return [Float] if the GC content is defined for the Sequence
  def gc
    s = self.downcase
    c = s.count('c')
    g = s.count('g')
    t = s.count('t')
    a = s.count('a')
    u = s.count('u')

    return 0 if c + g + t + a + u == 0
    return (c + g) / (c + g + t + a + u).to_f
  end

  # Returns a map of base counts
  #
  # This method will check if the sequence is DNA or RNA and return a
  # count map appropriate for each. If a truthy argument is given, the
  # count of ambiguous bases will be returned as well.
  #
  # If a sequence has both T and U present, will warn the user and
  # keep going. Will return a map with counts of both, however.
  #
  # @example Get base counts of DNA sequence without ambiguous bases
  #   Sequence.new('AcTGn').base_counts
  #   #=> { a: 1, c: 1, t: 1, g: 1 }
  # @example Get base counts of DNA sequence with ambiguous bases
  #   Sequence.new('AcTGn').base_counts(true)
  #   #=> { a: 1, c: 1, t: 1, g: 1, n: 1 }
  # @example Get base counts of RNA sequence without ambiguous bases
  #   Sequence.new('AcUGn').base_counts
  #   #=> { a: 1, c: 1, u: 1, g: 1 }
  # @example Get base counts of DNA sequence with ambiguous bases
  #   Sequence.new('AcUGn').base_counts(true)
  #   #=> { a: 1, c: 1, u: 1, g: 1, n: 1 }
  #
  # @return [Hash] A hash with base as key, count as value
  def base_counts(count_ambiguous_bases=nil)
    s = self.downcase
    t = s.count('t')
    u = s.count('u')
    counts = { a: s.count('a'), c: s.count('c'), g: s.count('g') }

    if t > 0 && u == 0
      counts[:t] = t
    elsif t == 0 && u > 0
      counts[:u] = u
    elsif t > 0 && u > 0
      warn('ERROR: A sequence contains both T and U')
      counts[:t], counts[:u] = t, u
    end

    counts[:n] = s.count('n') if count_ambiguous_bases

    counts
  end

  # Returns a map of base frequencies
  #
  # Counts bases with the `base_counts` method, then divides each
  # count by the total bases counted to give frequency for each
  # base. If a truthy argument is given, ambiguous bases will be
  # included in the total and their frequency reported. Can discern
  # between DNA and RNA.
  #
  # If default or falsy argument is given, ambiguous bases will not be
  # counted in the total base count and their frequency will not be
  # given.
  #
  # @example Get base frequencies of DNA sequence without ambiguous bases
  #   Sequence.new('AcTGn').base_counts
  #   #=> { a: 0.25, c: 0.25, t: 0.25, g: 0.25 }
  # @example Get base counts of DNA sequence with ambiguous bases
  #   Sequence.new('AcTGn').base_counts(true)
  #   #=> { a: 0.2, c: 0.2, t: 0.2, g: 0.2, n: 0.2 }
  #
  # @return [Hash] A hash with base as key, frequency as value
  def base_frequencies(count_ambiguous_bases=nil)
    base_counts = self.base_counts(count_ambiguous_bases)
    total_bases = base_counts.values.reduce(:+).to_f
    base_freqs =
      base_counts.map { |base, count| [base, count/total_bases] }.flatten
    Hash[*base_freqs]
  end
end
