require 'spec_helper'

describe MarkLogic::DatabaseSettings::RangeElementIndex do

  describe "new" do
    it "should populate correctly" do
      index = MarkLogic::DatabaseSettings::RangeElementIndex.new("element")
      expect(index.to_json).to eq(
        {
          "scalar-type" => "string",
          "namespace-uri" => "",
          "localname" => "element",
          "collation" => MarkLogic::DEFAULT_COLLATION,
          "range-value-positions" => false,
          "invalid-values" => "reject"
        }
      )
    end

    it "should populate correctly with namespace-uri" do
      index = MarkLogic::DatabaseSettings::RangeElementIndex.new("element", :namespace => "blah")
      expect(index.to_json).to eq(
        {
          "scalar-type" => "string",
          "namespace-uri" => "blah",
          "localname" => "element",
          "collation" => MarkLogic::DEFAULT_COLLATION,
          "range-value-positions" => false,
          "invalid-values" => "reject"
        }
      )
    end
  end
end
