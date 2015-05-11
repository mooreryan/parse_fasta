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

describe SeqFile do
  describe "#each_record" do

    context "when input is a fasta file" do
      let(:records) { Helpers::RECORDS }

      let(:f_handle) { SeqFile.open(@fname).each_record { |s| } }

      shared_examples_for "parsing a fasta file" do
        it "yields proper header and sequence for each record" do
          expect { |b|
            SeqFile.open(@fname).each_record(&b)
          }.to yield_successive_args(*records)
        end

        it "yields the sequence as a Sequence class" do
          SeqFile.open(@fname).each_record do |_, seq|
            expect(seq).to be_an_instance_of Sequence
          end
        end
      end

      context "with a gzipped file" do
        before(:each) do
          @fname = "#{File.dirname(__FILE__)}/../../test_files/test.fa.gz"
        end

        it_behaves_like "parsing a fasta file"

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

        it_behaves_like "parsing a fasta file"

        it "doesn't close the File (approx regular file behavior)" do
          expect(f_handle).not_to be_closed
        end

        it "returns FastaFile object" do
          expect(f_handle).to be_a FastaFile
        end
      end
    end
  end

  context "when input is a fastq file" do
    let(:records) {
      [["seq1", "AACCTTGG"],
       ["seq2 apples", "ACTG"]] }
    let(:f_handle) { SeqFile.open(@fname).each_record { |s| } }

    shared_examples_for "parsing a fastq file" do
      it "yields only header & sequence" do
        expect { |b|
          SeqFile.open(@fname).each_record(&b)
        }.to yield_successive_args(records[0], records[1])
      end

      it "yields the sequence as a Sequence class" do
        SeqFile.open(@fname).each_record do |_, seq, _, _|
          expect(seq).to be_an_instance_of Sequence
        end
      end
    end

    context "with a 4 line per record fastq file" do
      describe "#each_record" do
        context "with a gzipped file" do
          before(:each) do
            @fname =
              "#{File.dirname(__FILE__)}/../../test_files/test.fq.gz"
          end

          it_behaves_like "parsing a fastq file"

          it "closes the GzipReader" do
            expect(f_handle).to be_closed
          end

          it "returns GzipReader object" do
            expect(f_handle).to be_an_instance_of Zlib::GzipReader
          end
        end

        context "with a non-gzipped file" do
          before(:each) do
            @fname =
              "#{File.dirname(__FILE__)}/../../test_files/test.fq"
          end

          it_behaves_like "parsing a fastq file"

          it "doesn't close the SeqFile (approx reg file behav)" do
            expect(f_handle).not_to be_closed
          end

          it "returns FastqFile object" do
            expect(f_handle).to be_a FastqFile
          end
        end
      end
    end
  end

  context "when input is bogus" do
    it "raises an ArgumentError with message" do
      fname = "#{File.dirname(__FILE__)}/../../test_files/bogus.txt"
      err_msg = "Input does not look like FASTA or FASTQ"

      expect { SeqFile.open(fname).each_record do |h, s|
          puts [h, s].join ' '
        end
      }.to raise_error(ArgumentError, err_msg)
    end
  end
end
