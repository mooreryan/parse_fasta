require 'spec_helper'

describe FastaFile do
  describe "#each_record" do

    let(:fname) { "#{File.dirname(__FILE__)}/../../test_files/test.fa" }
    it "yields a block with header and sequence for each record in a fasta file" do
      seqs = []
      FastaFile.open(fname, 'r').each_record do |header, sequence|
        seqs << [header, sequence]
      end
      
      expect(seqs).to eq([["seq1 is fun", "AACTGGend"],
                          ["seq2", "AATCCTGend"],
                          ["seq3", "yyyyyyyyyyyyyyyend"]])

    end

    it "passes header of type string as first parameter" do
      sequence_class = nil
      FastaFile.open(fname, 'r').each_record do |header, sequence|
        sequence_class = sequence.class
        break
      end
      expect(sequence_class).to be Sequence
    end      
  end
end
