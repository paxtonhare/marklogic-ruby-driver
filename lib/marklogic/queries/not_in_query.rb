module MarkLogic
  module Queries
    class NotInQuery< BaseQuery
      def initialize(positive_query, negative_query)
        @positive_query = positive_query
        @negative_query = negative_query
      end

      def to_xqy
        %Q{cts:not-in-query(#{@positive_query.to_xqy},#{@negative_query.to_xqy})}
      end
    end
  end
end
