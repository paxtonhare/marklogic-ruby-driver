module MarkLogic
  module Queries
    class LocksFragmentQuery< BaseQuery
      def initialize(query)
        @query = query
      end

      def to_xqy
        %Q{cts:locks-fragment-query(#{@query.to_xqy})}
      end
    end
  end
end
