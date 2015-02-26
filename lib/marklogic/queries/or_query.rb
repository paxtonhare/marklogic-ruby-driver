module MarkLogic
  module Queries
    class OrQuery< BaseQuery
      def initialize(*args)
        @queries = args.flat_map{ |i| i }
      end

      def to_json
        {
          "or-query" => {
            "queries" => @queries.map do |q|
              q.to_json
            end
          }
        }
      end
    end
  end
end
