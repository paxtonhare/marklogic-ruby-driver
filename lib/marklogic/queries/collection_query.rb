module MarkLogic
  module Queries
    class CollectionQuery < BaseQuery
      def initialize(collection_uris)
        @collection_uris = collection_uris
      end

      def to_xqy
        uris = query_value(@collection_uris)
        %Q{cts:collection-query((#{uris}))}
      end
    end
  end
end
