module MarkLogic
  module DatabaseSettings
    class Index

      def self.from_json(type, json)
        case type
          when 'range-element-index'
            RangeElementIndex.from_json(json)
          when 'element-word-lexicon'
            ElementWordLexicon.from_json(json)
          when 'range-path-index'
            RangepathIndex.from_json(json)
          when 'range-field-index'
            RangeFieldIndex.from_json(json)
          when 'geospatial-element-index'
            GeospatialElementIndex.from_json(json)
          when 'geospatial-element-child-index'
            GeospatialElementChildIndex.from_json(json)
          when 'geospatial-element-pair-index'
            GeospatialElementPairIndex.from_json(json)
          when 'geospatial-path-index'
            GeospatialPathIndex.from_json(json)
          end
        end
      end
  end
end
