require 'spec_helper'

describe MarkLogic::DatabaseSettings::GeospatialElementIndex do
  let(:index) do
    MarkLogic::DatabaseSettings::GeospatialElementIndex.new("element")
  end

  describe "new" do
    it "should populate correctly" do
      expect(index.to_json).to eq(
        {
          "geospatial-element-index" => {
            "namespace-uri" => "",
            "localname" => "element",
            "coordinate-system" => "wgs84",
            "point-format" => "point",
            "range-value-positions" => false,
            "invalid-values" => "reject"
          }
        }
      )
    end
  end
end
