# Copyright 2014 Ryan Moore
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
    return (c + g).quo(c + g + t + a + u).to_f
  end

  def base_counts(count_ambiguous_bases=nil)
    s = self.downcase
    counts = { 
      a: s.count('a'), 
      c: s.count('c'), 
      t: s.count('t'),
      g: s.count('g') 
    }
    counts[:n] = s.count('n') if count_ambiguous_bases
      
    counts
  end
end
