module MarkLogic
  module Queries
    class AndNotQuery< BaseQuery
      def initialize(positive_query, negative_query)
        @positive_query = positive_query
        @negative_query = negative_query
      end

      def to_json
        {
          "and-not-query" => {
            "positive-query" => @positive_query,
            "negative-query" => @negative_query
          }
        }
      end
    end
  end
end
