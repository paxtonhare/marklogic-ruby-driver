module MarkLogic
  module Queries
    class BaseQuery

      def value_type(value)
        value_key = "number" if value.kind_of?(Numeric)
        value_key = "boolean" if value.kind_of?(TrueClass)
        value_key = "boolean" if value.kind_of?(FalseClass)
        value_key = "text" if value.kind_of?(String)
        value_key = "null" if value.nil?
        value_key
      end

      def add_sub_query(parent, query)
        query_json = query.to_json
        query_key = query_json.keys[0]
        parent[query_key] = query_json[query_key]
      end
    end
  end
end
