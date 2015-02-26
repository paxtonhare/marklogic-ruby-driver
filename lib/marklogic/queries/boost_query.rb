module MarkLogic
  module Queries
    class BoostQuery< BaseQuery
      def initialize(matching_query, boosting_query)
        @matching_query = matching_query
        @boosting_query = boosting_query
      end

      def to_json
        {
          "boost-query" => {
            "matching-query" => @matching_query,
             "boosting-query" => @boosting_query
          }
        }
      end
    end
  end
end
