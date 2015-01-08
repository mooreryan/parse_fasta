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

require 'spec_helper'

describe FastaFile do
  describe "#each_record" do
    let(:records) {
      [["seq1 is fun", "AACTGGNNN"],
       ["seq2", "AATCCTGNNN"],
       ["seq3", "yyyyyyyyyyyyyyyNNN"]]
    }

    let(:truthy_records) {
      [["seq1 is fun", ["AACTGGNNN"]],
       ["seq2", ["AAT", "CCTGNNN"]],
       ["seq3", ["yyyyyyyyyy", "yyyyy", "NNN"]]]
    }
    let(:f_handle) { FastaFile.open(@fname).each_record { |s| } }

    shared_examples_for "any FastaFile" do
      context "with no arguments" do
        it "yields proper header and sequence for each record" do
          expect { |b|
            FastaFile.open(@fname).each_record(&b)
          }.to yield_successive_args(*records)
        end

        it "yields the sequence as a Sequence class" do
          FastaFile.open(@fname).each_record do |_, seq|
            expect(seq).to be_an_instance_of Sequence
          end
        end
      end

      context "with a truthy argument" do
        it "yields proper header and sequence for each record" do
          expect { |b|
            FastaFile.open(@fname).each_record(1, &b)
          }.to yield_successive_args(*truthy_records)
        end

        it "yields the sequence as a Sequence class" do
          FastaFile.open(@fname).each_record(1) do |_, seq|
            all_Sequences = seq.map { |s| s.instance_of?(Sequence) }.all?
            expect(all_Sequences).to be true
          end
        end
        
      end
    end

    context "with a gzipped file" do
      before(:each) do
        @fname = "#{File.dirname(__FILE__)}/../../test_files/test.fa.gz"
      end

      it_behaves_like "any FastaFile"

      it "closes the GzipReader" do
        expect(f_handle).to be_closed
      end

      it "returns GzipReader object" do
        expect(f_handle).to be_an_instance_of Zlib::GzipReader
      end
    end

    context "with a non-gzipped file" do
      before(:each) do
        @fname = "#{File.dirname(__FILE__)}/../../test_files/test.fa"
      end

      it_behaves_like "any FastaFile"

      it "doesn't close the FastqFile (approx regular file behavior)" do
        expect(f_handle).not_to be_closed
      end

      it "returns FastaFile object" do
        expect(f_handle).to be_an_instance_of FastaFile
      end
    end
  end      
end

