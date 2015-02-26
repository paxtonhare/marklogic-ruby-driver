require 'spec_helper'

describe MarkLogic::DatabaseSettings::GeospatialElementPairIndex do
  let(:index) do
    MarkLogic::DatabaseSettings::GeospatialElementPairIndex.new("parent", "lat", "lon")
  end

  describe "new" do
    it "should populate correctly" do
      expect(index.to_json).to eq(
        {
          "geospatial-element-pair-index" => {
            "parent-namespace-uri" => "",
            "parent-localname" => "parent",
            "latitude-namespace-uri" => "",
            "latitude-localname" => "lat",
            "longitude-namespace-uri" => "",
            "longitude-localname" => "lon",
            "coordinate-system" => "wgs84",
            "range-value-positions" => false,
            "invalid-values" => "reject"
          }
        }
      )
    end
  end
end
