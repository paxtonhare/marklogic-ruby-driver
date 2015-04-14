module MarkLogic
  module Queries
    class DocumentFragmentQuery < BaseQuery
      def initialize(query)
        @query = query
      end

      def to_xqy
        %Q{cts:document-fragment-query(#{@query.to_xqy})}
      end
    end
  end
end
