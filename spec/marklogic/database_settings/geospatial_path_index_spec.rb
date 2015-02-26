require 'spec_helper'

describe MarkLogic::DatabaseSettings::GeospatialPathIndex do
  let(:index) do
    MarkLogic::DatabaseSettings::GeospatialPathIndex.new("/path/to/stuff")
  end

  describe "new" do
    it "should populate correctly" do
      expect(index.to_json).to eq(
        {
          "geospatial-path-index" => {
            "path-expression" => "/path/to/stuff",
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
