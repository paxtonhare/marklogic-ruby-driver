module MarkLogic
  module Queries
    class GeospatialQuery < BaseQuery
      def initialize(name, regions, options = {})
        @name = name
        @regions = regions
        @options = options || {}
        @weight = @options.delete(:weight) || 1.0
      end

      def options=(opts)
        @options = opts
      end

      def options
        opts = []
        @options.each do |k, v|
          dashed_key = k.to_s.gsub(/_/, '-')
          case k.to_s
          when "coordinate_system", "units", "type", "score_function", "slope_factor"
            opts << %Q{"#{dashed_key}=#{v}"}
          when /(boundaries)_included/
            opts << (v == true ? %Q{"#{$1}-included"} : %Q{"#{$1}-excluded"})
          when /([a-z\-]+_excluded)/
            opts << %Q{"#{dashed_key}"}
          when "cached"
            opts << (v == true ? %Q{"cached"} : %Q{"uncached"})
          when "zero", "synonym"
            opts << %Q{"#{dashed_key}"}
          # else
          #   opts << %Q{"#{v}"}
          end
        end

        opts
      end

      def to_xqy
        regions = query_value(@regions)
        %Q{cts:json-property-geospatial-query("#{@name}",(#{regions}),(#{options.join(',')}),#{@weight})}
      end
    end
  end
end
