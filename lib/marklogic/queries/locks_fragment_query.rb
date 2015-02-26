module MarkLogic
  module Queries
    class LocksFragmentQuery< BaseQuery
      def initialize(query)
        @query = query
      end

      def to_json
        json = {
          "locks-fragment-query" => { }
        }

        add_sub_query(json["locks-fragment-query"], @query)

        json
      end
    end
  end
end
