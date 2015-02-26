module MarkLogic
  module DatabaseSettings
    class RangeElementIndex

      attr_accessor :scalar_type, :localname, :namespace_uri, :collation, :range_value_positions, :invalid_values, :facet

      def initialize(name, options = {})
        @scalar_type = options[:type] || 'string'
        @localname = name.to_s
        @namespace_uri = options[:namespace] || ""
        @collation = options[:collation] || (@scalar_type == 'string' ? MarkLogic::DEFAULT_COLLATION : "")
        @range_value_positions = options[:range_value_positions] || false
        @invalid_values = options[:invalid_values] || MarkLogic::REJECT
        @facet = options[:facet] || false
      end

      def key
        %Q{#{self.class.to_s}-#{@localname}}
      end

      def <=>(other)
        localname <=> other.localname
      end

      def ==(other)
        self.class == other.class and
        scalar_type == other.scalar_type and
        localname = other.localname and
        namespace_uri = other.namespace_uri and
        collation == other.collation and
        range_value_positions == other.range_value_positions and
        invalid_values == other.invalid_values
      end

      def type
        "range-element-index"
      end

      def append_to_db(database)
        database.add_index("range-element-index", self)
      end

      def to_json(options = nil)
        {
          "scalar-type" => @scalar_type,
          "namespace-uri" => @namespace_uri,
          "localname" => @localname,
          "collation" => @collation,
          "range-value-positions" => @range_value_positions,
          "invalid-values" => @invalid_values
        }
      end

      def self.from_json(json)
        index = allocate
        index.from_json(json)
        index
      end

      def from_json(json)
        @scalar_type = json['scalar-type']
        @namespace_uri = json['namespace-uri']
        @localname = json['localname']
        @collation = json['collation']
        @range_value_positions = json['range-value-positions']
        @invalid_values = json['invalid-values']
        @facet = false
      end
    end
  end
end
