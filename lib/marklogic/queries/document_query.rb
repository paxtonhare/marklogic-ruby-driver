module MarkLogic
  module Queries
    class DocumentQuery < BaseQuery
      def initialize(uris)
        @uris = uris
      end

      def to_xqy
        uris = query_value(@uris)
        %Q{cts:document-query((#{uris}))}
      end
    end
  end
end
