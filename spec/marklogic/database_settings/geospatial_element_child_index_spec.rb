require 'spec_helper'

describe MarkLogic::DatabaseSettings::GeospatialElementChildIndex do
  let(:index) do
    MarkLogic::DatabaseSettings::GeospatialElementChildIndex.new("parent", "child")
  end

  describe "new" do
    it "should populate correctly" do
      expect(index.to_json).to eq(
        {
          "geospatial-element-child-index" => {
            "parent-namespace-uri" => "",
            "parent-localname" => "parent",
            "namespace-uri" => "",
            "localname" => "child",
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
