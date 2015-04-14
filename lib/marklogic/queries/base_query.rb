module MarkLogic
  module Queries
    class BaseQuery

      # Helper function to add a sub query into a parent query
      #
      # @param [ BaseQuery ] parent The parent query
      # @param [ BaseQuery ] query The sub-query to add
      #
      # @since 1.0.0
      def add_sub_query(parent, query)
        query_json = query.to_json
        query_key = query_json.keys[0]
        parent[query_key] = query_json[query_key]
      end

      # Returns the value of the query appropriately formatted
      #
      # @param [ Any ] original_value The value to format
      # @param [ String ] type The data type
      #
      # @since 1.0.0
      def query_value(original_value, type = nil)
        if original_value.kind_of?(Array)
          value = original_value.map { |v| query_value(v) }.join(',')
        elsif original_value.kind_of?(TrueClass)
          value = 'fn:true()'
        elsif original_value.kind_of?(FalseClass)
          value = 'fn:false()'
        elsif original_value.kind_of?(ObjectId)
          value = %Q{"#{original_value.to_s}"}
        elsif original_value.kind_of?(String) || type == "string"
          value = %Q{"#{original_value}"}
        else
          value = original_value
        end
      end
    end
  end
end
