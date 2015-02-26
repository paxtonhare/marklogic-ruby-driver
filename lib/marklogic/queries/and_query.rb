module MarkLogic
  module Queries
    class AndQuery< BaseQuery
      def initialize(*args)
        @queries = args.flat_map{ |i| i }
      end

      def to_json
        {
          "and-query" => {
            "queries" =>
              @queries.map do |q|
                q.to_json
              end
          }
        }
      end
    end
  end
end
