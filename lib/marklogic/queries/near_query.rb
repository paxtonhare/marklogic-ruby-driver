module MarkLogic
  module Queries
    class NearQuery< BaseQuery
      def initialize(queries, distance = nil, distance_weight = nil, ordered = false)
        @queries = args
        @distance = distance
        @distance_weight = distance_weight
        @ordered = ordered
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

      def xml_query
        %Q{<near-query>#{@queries.each { |q| q.xml_query }}</near-query>}
      end
    end
  end
end
