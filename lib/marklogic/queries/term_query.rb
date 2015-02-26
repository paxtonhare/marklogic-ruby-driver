module MarkLogic
  module Queries
    class TermQuery< BaseQuery
      def initialize(text, weight = 1.0)
        @text = text
        @weight = weight
      end

      def to_json
        {
          "term-query" => {
            "text" => @text,
            "weight" => @weight
          }
        }
      end
    end
  end
end
