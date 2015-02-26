require 'securerandom'

module MarkLogic
  class Collection

    attr_accessor :collection
    attr_reader :database

    alias_method :name, :collection
    def initialize(name, database)
      @collection = name
      @database = database
      @operators = %w{GT LT GE LE EQ NE ASC DESC}
    end

    def count
      MarkLogic::Cursor.new(self).count
    end

    def load(id)
      url = "/v1/documents?uri=#{gen_uri(id)}&format=json"
      response = @database.connection.get(url)
      raise Exception.new("Invalid response: #{response.code.to_i}, #{response.body}") unless response.code.to_i == 200
      JSON.parse(response.body)
    end

    def save(doc)
      id = doc[:_id] || doc['_id']
      # id ||= doc.values[0]['_id'] if doc.values and doc.values.length == 1
      if id.nil?
        id = SecureRandom.hex
        doc[:_id] = id
      end
      url = "/v1/documents?uri=#{gen_uri(id)}&format=json&collection=#{collection}"
      # puts "\nurl: #{url}\njson: #{JSON.generate(doc)}\n"
      json = JSON.generate(doc)
      response = @database.connection.put(url, json)
      raise Exception.new("Invalid response: #{response.code.to_i}, #{response.body}\n") unless [201, 204].include? response.code.to_i

      id
    end

    def update(selector, document, opts={})
      find(selector).each do |doc|
        document.each do |key, value|
          # puts "#{key} => #{value}"
          case key
          when "$set"
            value.each do |kk, vv|
              doc[kk.to_s] = vv
            end
          when "$inc"
            value.each do |kk, vv|
              prev = doc[kk.to_s] || 0
              doc[kk.to_s] = prev + vv
            end
          when "$unset"
            value.keys.each do |kk|
              doc.delete(kk.to_s)
            end
          when "$push"
            value.each do |kk, vv|
              if doc.has_key?(kk.to_s)
                doc[kk.to_s].push(vv)
              else
                doc[kk.to_s] = [vv]
              end
            end
          when "$pushAll"
            value.each do |kk, vv|
              if doc.has_key?(kk.to_s)
                doc[kk.to_s] = doc[kk.to_s] + vv
              else
                doc[kk.to_s] = vv
              end
            end
          end
          save(doc)
        end
      end
    end

    alias_method :create, :save
    alias_method :insert, :save

    def remove(query = nil, options = {})
      if query.nil?
        drop
      else
        cursor = find(query, options)
        cursor.each do |doc|
          url = "/v1/documents?uri=#{gen_uri(doc['_id'])}"
          response =@database.connection.delete(url)
          raise Exception.new("Invalid response: #{response.code.to_i}, #{response.body}") unless [204].include? response.code.to_i
        end
      end
    end

    def drop
      url = "/v1/search?collection=#{collection}"
      response =@database.connection.delete(url)
      raise Exception.new("Invalid response: #{response.code.to_i}, #{response.body}") unless [204].include? response.code.to_i
    end

    def find_one(query = nil, options = {})
      opts = options.merge(:per_page => 1)
      find(query, opts).next
    end

    def find(query = nil, options = {})
      if query.class == Hash
        query = from_criteria(query)
      elsif query.nil?
        query = Queries::AndQuery.new()
      end
      options[:query] = query
      cursor = MarkLogic::Cursor.new(self, options)

      if block_given?
        yield cursor
        nil
      else
        cursor
      end
    end

    def build_query(name, operator, value, query_options)
      if database.has_range_index?(name) && query_options[:term_options] != 'case-insensitive'
        index = database.range_index(name)
        type = index.scalar_type
        Queries::RangeQuery.new(name, operator, type, value, query_options)
      elsif operator != 'EQ'
        raise MissingIndexError.new("Missing index on #{name}")
      elsif value.nil?
        Queries::OrQuery.new([
          Queries::ValueQuery.new(name, value, query_options),
          Queries::NotQuery.new(Queries::ContainerQuery.new(name, Queries::AndQuery.new))
        ])
      elsif operator == 'EQ'
        Queries::ValueQuery.new(name, value, query_options)
      end
    end

    # Builds a MarkLogic Query from Mongo Style Criteria
    #
    # @param [Hash] criteria The Criteria to use when searching
    #
    # @example Build a query from criteria
    #
    #    # Query on age == 3
    #    collection.from_criteria({ 'age' => { '$eq' =>  3  } })
    #
    #    # Query on age < 3
    #    collection.from_criteria({ 'age' => { '$lt' =>  3  } })
    #
    #    # Query on age <= 3
    #    collection.from_criteria({ 'age' => { '$le' =>  3  } })
    #
    #    # Query on age > 3
    #    collection.from_criteria({ 'age' => { '$gt' =>  3  } })
    #
    #    # Query on age >= 3
    #    collection.from_criteria({ 'age' => { '$ge' =>  3  } })
    #
    #    # Query on age != 3
    #    collection.from_criteria({ 'age' => { '$ne' =>  3  } })
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
          query_options[:term_options] = v.delete(:term_options)

          sub_queries = []
          v.each do |kk, vv|
            operator = kk.to_s.gsub('$', '').upcase || "EQ"
            if @operators.include?(operator)
              value = vv
              value = value.to_s if value.is_a?(MarkLogic::ObjectId)
              sub_queries << build_query(name, operator, value, query_options)
            elsif value.is_a?(Hash)
              child_queries = value.map do |kk, vv|
                build_query(kk, vv, query_options)
              end
              sub_queries << Queries::ContainerQuery.new(name, Queries::AndQuery.new(child_queries))
            end
          end

          if sub_queries.length > 1
            queries << Queries::AndQuery.new(sub_queries)
          elsif sub_queries.length == 1
            queries << sub_queries[0]
          end
        #     operator = v.keys[0]
        #     value = v[operator]
        #     operator = operator.to_s.gsub('$', '').upcase
        #   elsif v.length > 1
        #     if (v[:term_options])
        #       query_options[:term_options] = v[:term_options]
        #       value = v[:value]
        #   elsif (v.is_a?(Hash))
        #     value = v
        #   else
        #     raise SearchError.new("Invalid query option: #{k} => #{v}")
        #   end
        else
          name = k.to_s
          value = v
          operator = "EQ"
          queries << build_query(name, operator, value, query_options)
        # end
        end

        # if value.class == MarkLogic::ObjectId
        #   value = value.to_s
        # end

        # operator ||= "EQ"

        # # puts "name: #{name}"
        # # puts "value: #{value}"
        # # puts "operator: #{operator}"

        # if database.has_range_index?(name) && operator != "in" && !value.is_a?(Hash)
        #   index = database.range_index(name)
        #   type = index.scalar_type
        #   queries << Queries::RangeQuery.new(name, operator, type, value, query_options)
        # elsif operator != 'EQ' #([:sort, :order].include?(k) and operator != "in") or k.is_a?(Hash)
        #   binding.pry
        #   raise MissingIndexError.new("Missing index on #{name}")
        # # handle compound keys
        # elsif value.is_a?(Hash)
        #   child_queries = value.map do |kk, vv|
        #     Queries::ValueQuery.new(kk, vv, query_options)
        #   end
        #   queries << Queries::ContainerQuery.new(name, Queries::AndQuery.new(child_queries))
        # # handle a query for a nil value so that it will find when values are also missing
        # elsif value.nil?
        #   queries << Queries::OrQuery.new([
        #     Queries::ValueQuery.new(name, value, query_options),
        #     Queries::NotQuery.new(Queries::ContainerQuery.new(name, Queries::AndQuery.new))
        #   ])
        # else
        #   queries << Queries::ValueQuery.new(name, value, query_options)
        # end
      end

      if queries.length > 1
        MarkLogic::Queries::AndQuery.new(*queries)
      elsif queries.length == 1
        queries[0]
      end
    end

    private

    def gen_uri(id)
      if id.is_a?(Hash)
        id_str = id.hash.to_s
      else
        id_str = id.to_s
      end
      %Q{/#{collection}/#{id_str}.json}
    end
  end
end
