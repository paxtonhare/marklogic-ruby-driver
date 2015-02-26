module MarkLogic
  module Queries
    class CollectionQuery< BaseQuery
      def initialize(collection_uri)
        @collection_uri = collection_uri
      end

      def to_json
        {
          "collection-query" => {
            "uri" => @collection_uri
          }
        }
      end

    end
  end
end
