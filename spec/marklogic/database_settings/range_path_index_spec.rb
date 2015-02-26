require 'spec_helper'

describe MarkLogic::DatabaseSettings::RangePathIndex do
  let(:index) do
    MarkLogic::DatabaseSettings::RangePathIndex.new("/path/to/stuff")
  end

  describe "new" do
    it "should populate correctly" do
      expect(index.to_json).to eq(
        {
          "range-path-index" => {
            "scalar-type" => "string",
            "collation" => MarkLogic::DEFAULT_COLLATION,
            "path-expression" => "/path/to/stuff",
            "range-value-positions" => false,
            "invalid-values" => "reject"
          }
        }
      )
    end
  end
end
