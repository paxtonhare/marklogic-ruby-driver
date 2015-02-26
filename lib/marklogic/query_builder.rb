module MarkLogic
  class QueryBuilder

    # Creates a QueryBuilder Object
    #
    # @example Instantiate the QueryBuilder.
    #   qb = MarkLogic::QueryBuilder.new(collection)
    #
    # @param [Collection] collection A MarkLogic::Collection
    #
    # @since 0.0.1
    def initialize(collection)
      @collection = collection
    end

    # Builds a MarkLogic Query from Mongo Style Criteria
    #
    # @param [Hash] criteria The Criteria to use when searching
    #
    # @example Build a query from criteria
    #
    #    # Query on age == 3
    #    qb.from_criteria({ 'age' => { '$eq' =>  3  } })
    #
    #    # Query on age < 3
    #    qb.from_criteria({ 'age' => { '$lt' =>  3  } })
    #
    #    # Query on age <= 3
    #    qb.from_criteria({ 'age' => { '$le' =>  3  } })
    #
    #    # Query on age > 3
    #    qb.from_criteria({ 'age' => { '$gt' =>  3  } })
    #
    #    # Query on age >= 3
    #    qb.from_criteria({ 'age' => { '$ge' =>  3  } })
    #
    #    # Query on age != 3
    #    qb.from_criteria({ 'age' => { '$ne' =>  3  } })
    #
    # @since 0.0.1
    def from_criteria(criteria)
      queries = []

      criteria.each do |k, v|
        name, operator, index_type, value = nil
        query_options = {}

        if (v.is_a?(Hash))
          # puts "v: #{v}"
          name = k.to_s
          if (v.length == 1)
            operator = v.keys[0]
            value = v[operator]
            operator = operator.to_s.gsub('$', '').upcase
          elsif (v[:term_options])
            query_options[:term_options] = v[:term_options]
            value = v[:value]
          else
            raise SearchError.new("Invalid query option: #{k} => #{v}")
          end
        else
          name = k.to_s
          value = v
        end

        operator ||= "EQ"

        # puts "name: #{name}"
        # puts "value: #{value}"
        # puts "operator: #{operator}"

        if @collection.database.has_range_index?(name) and operator != "in"
          index = @collection.database.range_index(name)
          type = index.scalar_type
          queries << Queries::RangeQuery.new(name, operator, type, value, query_options)
        elsif operator != 'EQ' #([:sort, :order].include?(k) and operator != "in") or k.is_a?(Hash)
          raise MissingIndexError.new("Missing index on #{value[0]}")
        else
          queries << Queries::ValueQuery.new(name, value, query_options)
        end
      end

      if queries.length > 1
        MarkLogic::Queries::AndQuery.new(*queries)
      elsif queries.length == 1
        queries[0]
      end
    end
  end
end
