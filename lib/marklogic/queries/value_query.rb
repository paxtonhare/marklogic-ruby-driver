module MarkLogic
  module Queries
    class ValueQuery< BaseQuery
      def initialize(name, value, options = {})
        @name = name.to_s
        @value = value
        @value = value.to_s if value.is_a?(ObjectId)
        @options = options || {}
        @weight = @options.delete(:weight) || 1.0
        @options[:exact] = true if @options.length == 0
      end

      def options=(opts)
        @options = opts
      end

      def options
        opts = []
        @options.each do |k, v|
          dashed_key = k.to_s.gsub(/_/, '-')
          case k.to_s
          when "lang", "min_occurs", "max_occurs"
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
        value = query_value(@value)
        %Q{cts:json-property-value-query("#{@name}",(#{value}),(#{options.join(',')}),#{@weight})}
      end
    end
  end
end
