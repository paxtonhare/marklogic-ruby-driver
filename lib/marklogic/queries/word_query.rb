module MarkLogic
  module Queries
    class WordQuery< BaseQuery
      def initialize(name, value, options = {})
        @name = name.to_s
        @value = value
        @options = options
      end

      def to_json
        json = {
          "word-query" => {
            "json-property" => @name,
             "text" => [@value]
          }
        }

        json["word-query"]["type"] = value_key if value_key != "text"
        json["word-query"]["fragment-scope"] = @options[:fragment_scope] if @options[:fragment_scope]
        json["word-query"]["term-options"] = @options[:term_options] if @options[:term_options]
        json["word-query"]["weight"] = @options[:weight] if @options[:weight]

        json
      end
    end
  end
end
