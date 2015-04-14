module MarkLogic
  module Queries
    class AndQuery < BaseQuery
      def initialize(*args)
        @queries = args.flat_map{ |i| i }
      end

      def to_xqy
        sub_queries = @queries.map { |q| q.to_xqy }.join(',')
        %Q{cts:and-query((#{sub_queries}))}
      end
    end
  end
end
