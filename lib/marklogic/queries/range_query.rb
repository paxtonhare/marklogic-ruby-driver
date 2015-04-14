module MarkLogic
  module Queries
    class RangeQuery < BaseQuery

      attr_accessor :name, :range_type

      def initialize(name, operator, range_type, value, options = {})
        @name = name.to_s
        @operator = operator.to_s.upcase
        @range_type = range_type
        @value = value
        @options = options || {}
        @weight = @options.delete(:weight) || 1.0
      end

      def operator=(op)
        @operator = op
      end

      def operator
        case @operator
          when "LT"
            "<"
          when "LE"
            "<="
          when "GT"
            ">"
          when "GE"
            ">="
          when "EQ"
            "="
          when "NE"
            "!="
          else
            @operator
        end
      end

      def options=(opts)
        @options = opts
      end

      def options
        opts = []
        @options.each do |k, v|
          case k.to_s
          when "collation", "min_occurs", "max_occurs", "score_function", "slope_factor"
            opts << %Q{"#{k.to_s.gsub(/_/, '-')}=#{v}"}
          when "cached"
            opts << (v == true ? %Q{"cached"} : %Q{"uncached"})
          when "synonym"
            opts << %Q{"#{k}"}
          else
            opts << %Q{"#{v}"}
          end
        end

        opts
      end

      def to_xqy
        value = query_value(@value, @range_type)
        %Q{cts:json-property-range-query("#{@name}","#{operator}",(#{value}),(#{options.join(',')}),#{@weight})}
      end
    end
  end
end
