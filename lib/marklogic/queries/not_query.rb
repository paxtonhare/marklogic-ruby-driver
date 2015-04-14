module MarkLogic
  module Queries
    class NotQuery< BaseQuery
      def initialize(query)
        @query = query
      end

      def to_xqy
        %Q{cts:not-query(#{@query.to_xqy})}
      end
    end
  end
end
