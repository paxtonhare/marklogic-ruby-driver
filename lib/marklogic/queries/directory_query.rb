module MarkLogic
  module Queries
    class DirectoryQuery< BaseQuery
      def initialize(uris, depth = nil)
        @directory_uris = uris
        @depth = depth
      end

      def to_xqy
        uris = query_value(@directory_uris)

        if @depth.nil?
          %Q{cts:directory-query((#{uris}))}
        else
          %Q{cts:directory-query((#{uris}),"#{@depth}")}
        end
      end
    end
  end
end
