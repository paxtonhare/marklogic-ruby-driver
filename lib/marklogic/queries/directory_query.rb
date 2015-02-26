module MarkLogic
  module Queries
    class DirectoryQuery< BaseQuery
      def initialize(dir, infinite = true)
        @dir_uri = dir
        @infinite = infinite
      end

      def to_json
        {
          "directory-query" => {
            "uri" => @dir_uri,
            "infinite" => @infinite
          }
        }
      end
    end
  end
end
