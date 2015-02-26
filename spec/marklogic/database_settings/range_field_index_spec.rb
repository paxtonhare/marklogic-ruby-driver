require 'spec_helper'

describe MarkLogic::DatabaseSettings::RangeFieldIndex do
  let(:index) do
    MarkLogic::DatabaseSettings::RangeFieldIndex.new("field")
  end

  describe "new" do
    it "should populate correctly" do
      expect(index.to_json).to eq(
        {
          "range-field-index" => {
            "scalar-type" => "string",
            "field-name" => "field",
            "collation" => MarkLogic::DEFAULT_COLLATION,
            "range-value-positions" => false,
            "invalid-values" => "reject"
          }
        }
      )
    end
  end
end
