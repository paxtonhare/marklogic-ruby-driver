module MarkLogic
  module Queries
    class BoostQuery< BaseQuery
      def initialize(matching_query, boosting_query)
        @matching_query = matching_query
        @boosting_query = boosting_query
      end

      def to_xqy
        %Q{cts:boost-query(#{@matching_query.to_xqy},#{@boosting_query.to_xqy})}
      end
    end
  end
end
