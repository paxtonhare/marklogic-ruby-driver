module MarkLogic
  module DatabaseSettings
    class GeospatialPathIndex

      attr_accessor :path_expression, :facet

      def initialize(path_expression, options = {})
        @path_expression = path_expression
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
        database.add_index("geospatial-path-index", self)
      end

      def to_json(options = nil)
        {
          "geospatial-path-index" => {
            "path-expression" => @path_expression,
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
