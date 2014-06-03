require 'spec_helper'

describe File do
  describe "#each_record" do
    it "yields a block with header and sequence for each record in a fasta file" do
      fname = "#{File.dirname(__FILE__)}/../../test_files/test.fa"
      seqs = []
      File.open(fname, 'r').each_record do |header, sequence|
        seqs << [header, sequence]
      end
        
      expect(seqs).to eq([["seq1 is fun", "AACTGGend"],
                          ["seq2", "AATCCTGend"],
                          ["seq3", "yyyyyyyyyyyyyyyend"]])

    end
  end
end

