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
  describe "::open" do
    context "when input is bogus" do
      it "raises a ParseFasta::DataFormatError with message" do
        fname = "#{File.dirname(__FILE__)}/../../test_files/bogus.txt"

        expect { FastaFile.open(fname).each_record do |h, s|
            puts [h, s].join ' '
          end
        }.to raise_error ParseFasta::DataFormatError
      end
    end

    let(:fasta) { "#{File.dirname(__FILE__)}/../../test_files/test.fa" }

    it "takes all the wacky args like IO.open" do
      expect {
        FastaFile.open(fasta, mode: 'r', cr_newline: true)
      }.not_to raise_error
    end

    it "returns a FastaFile" do
      expect(FastaFile.open(fasta)).to be_a FastaFile
    end
  end

  describe "#to_hash" do
    let(:records) { Helpers::RECORDS_MAP }
    let(:fname) { "#{File.dirname(__FILE__)}/../../test_files/test.fa.gz" }
    let(:fasta) { FastaFile.open(fname) }

    context "with badly catted fasta" do
      it "raises ParseFasta::SequenceFormatError" do
        fname = "#{File.dirname(__FILE__)}/../../test_files/bad.fa"

        expect { FastaFile.open(fname).to_hash }.
          to raise_error ParseFasta::SequenceFormatError
      end
    end

    it "reads the records into a hash: header as key and seq as val" do
      expect(fasta.to_hash).to eq records
    end

    it "passes the values as Sequence objects" do
      expect(
        fasta.to_hash.values.all? { |val| val.instance_of? Sequence }
      ).to eq true
    end
  end

  describe "#each_record" do
    let(:records) { Helpers::RECORDS }

    let(:truthy_records) { Helpers::TRUTHY_RECORDS }
    let(:f_handle) { FastaFile.open(@fname).each_record { |s| } }

    context "with badly catted fasta" do
      it "raises ParseFasta::SequenceFormatError" do
        fname = "#{File.dirname(__FILE__)}/../../test_files/bad.fa"

        expect { FastaFile.open(fname).each_record {} }.
          to raise_error ParseFasta::SequenceFormatError
      end
    end

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

  describe "#each_record_fast" do
    let(:records) { Helpers::RECORDS_FAST }

    let(:f_handle) { FastaFile.open(@fname).each_record_fast { |s| } }

    context "with badly catted fasta" do
      it "raises ParseFasta::SequenceFormatError" do
        fname = "#{File.dirname(__FILE__)}/../../test_files/bad.fa"

        expect { FastaFile.open(fname).each_record_fast {} }.
          to raise_error ParseFasta::SequenceFormatError
      end
    end

    shared_examples_for "any FastaFile" do
      it "yields proper header and sequence for each record" do
        expect { |b|
          FastaFile.open(@fname).each_record_fast(&b)
        }.to yield_successive_args(*records)
      end

      it "yields the sequence as a String class" do
        FastaFile.open(@fname).each_record_fast do |_, seq|
          expect(seq).to be_an_instance_of String
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
