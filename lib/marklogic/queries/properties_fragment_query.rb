module MarkLogic
  module Queries
    class PropertiesFragmentQuery< BaseQuery
      def initialize(query)
        @query = query
      end

      def to_xqy
        %Q{cts:properties-fragment-query(#{@query.to_xqy})}
      end
    end
  end
end
