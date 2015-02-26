module MarkLogic
  module Queries
    class ContainerQuery< BaseQuery
      def initialize(name, query, options = {})
        @name = name
        @query = query
        @options = options
      end

      def to_json
        json = {
          "container-query" => {
            "json-property" => @name
          }
        }

        add_sub_query(json["container-query"], @query)

        json["container-query"]["fragment-scope"] = @options[:fragment_scope] if @options[:fragment_scope]
        json
      end
    end
  end
end
