module MarkLogic
  module Queries
    class NotInQuery< BaseQuery
      def initialize(positive_query, negative_query)
        @positive_query = positive_query
        @negative_query = negative_query
      end

      def to_json
        {
          "not-in-query" => {
            "positive-query" => @positive_query,
            "negative-query" => @negative_query
          }
        }
      end
    end
  end
end
