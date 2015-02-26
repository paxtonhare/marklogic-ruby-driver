module MarkLogic
  module Queries
    class PropertiesFragmentQuery< BaseQuery
      def initialize(query)
        @query = query
      end

      def to_json
        json = {
          "properties-fragment-query" => { }
        }

        add_sub_query(json["properties-fragment-query"], @query)
        json
      end
    end
  end
end
