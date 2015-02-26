module MarkLogic
  module DatabaseSettings
    class GeospatialElementPairIndex

      attr_accessor :parent_localname, :latitude_localname, :longitude_localname, :facet

      def initialize(element_name, latitude_localname, longitude_localname, options = {})
        @parent_localname = element_name
        @latitude_localname = latitude_localname
        @longitude_localname = longitude_localname
        @coordinate_system = options[:coordinate_system] || MarkLogic::GEO_WGS84
        @range_value_positions = options[:range_value_positions] || false
        @invalid_values = options[:invalid_values] || MarkLogic::REJECT
        @facet = options[:facet] || false
      end

      def key
        %Q{#{self.class.to_s}-#{@localname}}
      end

      def append_to_db(database)
        database.add_index("geospatial-element-pair-index", self)
      end

      def to_json(options = nil)
        {
          "geospatial-element-pair-index" => {
            "parent-namespace-uri" => "",
            "parent-localname" => @parent_localname,
            "latitude-namespace-uri" => "",
            "latitude-localname" => @latitude_localname,
            "longitude-namespace-uri" => "",
            "longitude-localname" => @longitude_localname,
            "coordinate-system" => @coordinate_system,
            "range-value-positions" => @range_value_positions,
            "invalid-values" => @invalid_values
          }
        }
      end
    end
  end
end
