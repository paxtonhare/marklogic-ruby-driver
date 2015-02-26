module MarkLogic
  module DatabaseSettings
    class GeospatialElementChildIndex

      attr_accessor :parent_localname, :localname, :facet

      def initialize(parent_localname, child_localname, options = {})
        @parent_localname = parent_localname
        @localname = child_localname
        @coordinate_system = options[:coordinate_system] || MarkLogic::GEO_WGS84
        @point_format = options[:point_format] || MarkLogic::POINT
        @range_value_positions = options[:range_value_positions] || false
        @invalid_values = options[:invalid_values] || MarkLogic::REJECT
        @facet = options[:facet] || false
      end

      def key
        %Q{#{self.class.to_s}-#{@localname}}
      end

      def append_to_db(database)
        database.add_index("geospatial-element-child-index", self)
      end

      def to_json(options = nil)
        {
          "geospatial-element-child-index" => {
            "parent-namespace-uri" => "",
            "parent-localname" => @parent_localname,
            "namespace-uri" => "",
            "localname" => @localname,
            "coordinate-system" => @coordinate_system,
            "point-format" => @point_format,
            "range-value-positions" => @range_value_positions,
            "invalid-values" => @invalid_values
          }
        }
      end
    end
  end
end
