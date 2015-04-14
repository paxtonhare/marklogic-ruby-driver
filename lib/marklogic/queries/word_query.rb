module MarkLogic
  module Queries
    class WordQuery< BaseQuery
      def initialize(values, options = {})
        @values = values
        @options = options || {}
        @weight = @options.delete(:weight) || 1.0
        @options[:exact] = true if @options.length == 0
      end

      def options
        opts = []
        @options.each do |k, v|
          dashed_key = k.to_s.gsub(/_/, '-')
          case k.to_s
          when "lang", "distance_weight", "min_occurs", "max_occurs", "lexicon_expand"
            opts << %Q{"#{dashed_key}=#{v}"}
          when /(case|diacritic|punctuation|whitespace)_sensitive/
            opts << (v == true ? %Q{"#{$1}-sensitive"} : %Q{"#{$1}-insensitive"})
          when "exact"
            opts << %Q{"#{dashed_key}"}
          when "stemmed", "wildcarded"
            opts << (v == true ? %Q{"#{dashed_key}"} : %Q{"un#{dashed_key}"})
          else
            opts << %Q{"#{v}"}
          end
        end

        opts
      end

      def to_xqy
        values = query_value(@values)
        %Q{cts:word-query((#{values}),(#{options.join(',')}),#{@weight})}
      end
    end
  end
end
