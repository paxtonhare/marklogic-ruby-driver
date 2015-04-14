module MarkLogic
  module Queries
    class AndNotQuery < BaseQuery
      def initialize(positive_query, negative_query)
        @positive_query = positive_query
        @negative_query = negative_query
      end

      def to_xqy
        %Q{cts:and-not-query(#{@positive_query.to_xqy},#{@negative_query.to_xqy})}
      end
    end
  end
end
