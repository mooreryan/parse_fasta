require 'spec_helper'

describe FastqFile do
  describe "#each_record" do
    let(:fname) { "#{File.dirname(__FILE__)}/../../test_files/test.fq" }

    context "with a 4 line per record fastq file" do
      it "yields the header, sequence, desc, and qual" do
        records = []
        FastqFile.open(fname, 'r').each_record do |head, seq, desc, qual|
          records << [head, seq, desc, qual]
        end
        
        expect(records).to eq([["seq1", "AACCTTGG", "", ")#3gTqN8"],
                               ["seq2 apples", "ACTG", "seq2 apples",
                                "*ujM"]])
      end      
    end
  end
end
