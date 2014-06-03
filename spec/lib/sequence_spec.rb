require 'spec_helper'

describe Sequence do
  describe "#gc" do
    context "when sequence isn't empty" do
      it "calculates gc" do
        s = Sequence.new('ActGnu')
        expect(s.gc).to eq(2.quo(5))
      end
    end

    context "when sequence is empty" do
      it "returns 0" do
        s = Sequence.new('')
        expect(s.gc).to eq 0
      end
    end

    context "there are no A, C, T, G or U (ie only N)" do
      it "returns 0" do
        s = Sequence.new('NNNNNnn')
        expect(s.gc).to eq 0
      end
    end
  end
end
