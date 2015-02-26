module MarkLogic
  module DatabaseSettings
    class RangePathIndex

      attr_accessor :scalar_type, :collation, :path_expression, :facet

      def initialize(path_expression, options = {})
        @scalar_type = options[:type] || MarkLogic::STRING
        @collation = options[:collation] || DEFAULT_COLLATION
        @path_expression = path_expression
        @range_value_positions = options[:range_value_positions] || false
        @invalid_values = options[:invalid_values] || MarkLogic::REJECT
        @facet = options[:facet] || false
      end

      def key
        %Q{#{self.class.to_s}-#{@localname}}
      end

      def append_to_db(database)
        database.add_index("range-path-index", self)
      end

      def to_json(options = nil)
        {
          "range-path-index" => {
            "scalar-type" => @scalar_type,
            "collation" => @collation,
            "path-expression" => @path_expression,
            "range-value-positions" => @range_value_positions,
            "invalid-values" => @invalid_values
          }
        }
      end
    end
  end
end
