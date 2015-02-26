module MarkLogic
  module DatabaseSettings
    class ElementWordLexicon
      def initialize(localname, collation = DEFAULT_COLLATION)
        @localname = localname
        @collation = collation
      end

      def append_to_db(database)
        database.add_index("element-word-lexicon", self)
      end

      def key
        %Q{#{self.class.to_s}-#{@localname}}
      end

      def to_json(options = nil)
        {
          "element-word-lexicon" => {
            "namespace-uri" => "",
            "localname" => @localname,
            "collation" => @collation
          }
        }
      end
    end
  end
end
