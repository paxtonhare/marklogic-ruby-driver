module MarkLogic
  module Queries
    class DocumentFragmentQuery< BaseQuery
      def initialize(query)
        @query = query
      end

      def to_json
        json = {
          "document-fragment-query" => { }
        }

        add_sub_query(json["document-fragment-query"], @query)

        json
      end
    end
  end
end
