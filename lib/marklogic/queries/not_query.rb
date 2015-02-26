module MarkLogic
  module Queries
    class NotQuery< BaseQuery
      def initialize(query)
        @query = query
      end

      def to_json
        json = {
          "not-query" => { }
        }
        add_sub_query(json["not-query"], @query)
        json
      end
    end
  end
end
