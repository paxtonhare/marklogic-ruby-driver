module MarkLogic
  module Queries
    class DocumentQuery< BaseQuery
      def initialize(document_uri)
        @document_uri = document_uri
      end

      def to_json
        {
          "document-query" => {
            "uri" => document_uri
          }
        }
      end
    end
  end
end
