module MarkLogic
  module Queries
    class NearQuery< BaseQuery
      def initialize(queries, distance = 10, distance_weight = 1.0, options = {})
        @queries = queries
        @distance = distance
        @distance_weight = distance_weight
        @ordered = options.delete(:ordered)
      end

      def to_json
        json = {
          "near-query" => {
            "queries" => @queries.map { |q| q.to_json }
          }
        }

        json["near-query"]["queries"].push({ "distance" => @distance }) if @distance
        json["near-query"]["queries"].push({ "distance-weight" => @distance_weight }) if @distance_weight
        json["near-query"]["queries"].push({ "ordered" => @ordered })
        json
      end

      def to_xqy
        queries = @queries.map { |q| q.to_xqy }.join(',')
        ordered = (@ordered == true ? %Q{"ordered"} : %Q{"unordered"}) if !@ordered.nil?
        %Q{cts:near-query((#{queries}),#{@distance},(#{ordered}),#{@distance_weight})}
      end
    end
  end
end
