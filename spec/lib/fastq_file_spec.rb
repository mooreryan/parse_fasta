require 'spec_helper'

describe FastqFile do
  describe "#each_record" do
    let(:fname) { "#{File.dirname(__FILE__)}/../../test_files/test.fq" }

    context "with a 4 line per record fastq file" do
      before do
        @records = []
        FastqFile.open(fname, 'r').each_record do |head, seq, desc, qual|
          @records << [head, seq, desc, qual]
        end
      end

      it "yields the header, sequence, desc, and qual" do
        expect(@records).to eq([["seq1", "AACCTTGG", "", ")#3gTqN8"],
                               ["seq2 apples", "ACTG", "seq2 apples",
                                "*ujM"]])
      end
      
      it "yields the sequence as a Sequence class" do
        the_sequence = @records[0][1]
        expect(the_sequence).to be_a(Sequence)
      end

      it "yields the quality string as a Quality class" do
        the_quality = @records[0][3]
        expect(the_quality).to be_a(Quality)
      end
    end
  end
end
