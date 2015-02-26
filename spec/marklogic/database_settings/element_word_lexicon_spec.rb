require 'spec_helper'

describe MarkLogic::DatabaseSettings::ElementWordLexicon do
  let(:index) do
    MarkLogic::DatabaseSettings::ElementWordLexicon.new("element")
  end

  context "#new" do
    it "should populate correctly" do
      expect(index.to_json).to eq(
        {
          "element-word-lexicon" => {
            "namespace-uri" => "",
            "localname" => "element",
            "collation" => MarkLogic::DEFAULT_COLLATION
          }
        }
      )
    end
  end
end
