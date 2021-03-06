require "spec_helper"

module ParseFasta
  module CoreExt
    describe String do
      Object::String.include ParseFasta::CoreExt::String

      describe "#remove_gaps" do
        it "removes all gaps from alignment" do
          aln = "--A----C-tG---"
          expected = "ACtG"

          expect(aln.remove_gaps).to eq expected
        end

        it "returns empty string if all chars are gap chars" do
          aln = "-----"
          expected = ""

          expect(aln.remove_gaps).to eq expected
        end

        it "can take a different gap char" do
          aln = "-N-nACTG"
          expected = "--nACTG"

          expect(aln.remove_gaps "N").to eq expected
        end

        it "can handle multiple weird gap chars" do
          # The '-' and '^' chars are treated specially by String#tr.
          aln = ".A----C_t~~~~g^G3"
          expected = "ACtgG"

          expect(aln.remove_gaps '^._-~3').to eq expected
        end
      end
    end
  end
end
