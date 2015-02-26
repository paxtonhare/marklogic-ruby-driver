module MarkLogic
  module Queries
    class RangeQuery< BaseQuery
      def initialize(name, operator, range_type, value, options = {})
        @name = name.to_s
        @operator = operator.to_s.upcase
        @range_type = range_type
        @value = value
        @options = options
      end

      def to_json
        value_key = value_type(@value)
        json = {
          "range-query" => {
            "type" => @range_type,
            "json-property" => @name,
             "value" => @value,
             "range-operator" => @operator
          }
        }

        json["range-query"]["fragment-scope"] = @options[:fragment_scope] if @options[:fragment_scope]
        json["range-query"]["collation"] = @options[:collation] if @options[:collation]
        json
      end
    end
  end
end
