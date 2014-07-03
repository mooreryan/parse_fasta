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
# quality strings.
class Quality < String
  # Returns the mean quality for the record. This will be a good deal
  # faster than getting the average with `qual_scores` and reduce.
  #
  # @example Get mean quality score for a record
  #   Quality.new("!+5?I").mean_qual #=> 20.0
  #
  # @return [Float] Mean quality score for record
  def mean_qual
    (self.sum - (self.length * 33)) / self.length.to_f
  end

  # Returns an array of illumina style quality scores. The quality
  # scores generated will be Phred+33 (i.e., new Illumina).
  #
  # @example Get quality score array of a Quality
  #   Quality.new("!+5?I").qual_scores #=> [0, 10, 20, 30, 40]
  #
  # @return [Array<Fixnum>] the quality scores
  def qual_scores
    self.each_byte.map { |b| b - 33 }
  end
end
