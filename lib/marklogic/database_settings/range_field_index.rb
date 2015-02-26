module MarkLogic
  module DatabaseSettings
    class RangeFieldIndex

      attr_accessor :scalar_type, :field_name, :collation, :facet

      def initialize(field_name, options = {})
        @scalar_type = options[:type] || MarkLogic::STRING
        @field_name = field_name
        @collation = options[:collation] || DEFAULT_COLLATION
        @range_value_positions = options[:range_value_positions] || false
        @invalid_values = options[:invalid_values] || MarkLogic::REJECT
        @facet = options[:facet] || false
      end

      def key
        %Q{#{self.class.to_s}-#{@localname}}
      end

      def append_to_db(database)
        database.add_index("range-field-index", self)
      end

      def to_json(options = nil)
        {
          "range-field-index" => {
            "scalar-type" => @scalar_type,
            "field-name" => @field_name,
            "collation" => @collation,
            "range-value-positions" => @range_value_positions,
            "invalid-values" => @invalid_values
          }
        }
      end
    end
  end
end
