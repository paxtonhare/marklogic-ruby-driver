module MarkLogic
  module Queries
    class ValueQuery< BaseQuery
      def initialize(name, value, options = {})
        @name = name.to_s
        @value = value
        @value = value.to_s if value.is_a?(ObjectId)
        @options = options
        @options[:term_options] ||= "exact"
      end

      def to_json
        if @value.kind_of?(Array)
          value_key = value_type(@value[0])
        else
          value_key = value_type(@value)
        end

        json = {
          "value-query" => {
            "json-property" => @name,
             "text" => @value
          }
        }

        json["value-query"]["type"] = value_key if value_key != "text"
        json["value-query"]["fragment-scope"] = @options[:fragment_scope] if @options[:fragment_scope]
        json["value-query"]["term-option"] = @options[:term_options] if @options[:term_options]
        json["value-query"]["weight"] = @options[:weight] if @options[:weight]

        json
      end
    end
  end
end
