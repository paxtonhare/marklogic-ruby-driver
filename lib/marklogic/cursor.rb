require 'pp'
module MarkLogic
  class Cursor
    include Enumerable

    attr_accessor :queries

    DEFAULT_PAGE_LENGTH = 25

    def initialize(collection, options = {})
      @options = options || {}
      @query = options.delete(:query)
      @collection = collection
      @transformer = options.delete(:transformer)
      @fields = options.delete(:fields)
      @fields = convert_fields_for_query(@fields) if @fields
      @connection = @collection.database.connection
      @limit = options.delete(:limit)
      @cache = []
      @query_run = false
      @visited = 0
    end

    def count
      col_name = collection.nil? ? "" : %Q{"#{collection.collection}"}
      query_to_run = %Q{xdmp:estimate(cts:search(fn:collection(#{col_name}), #{query.to_xqy}, ("unfiltered")))}
      response = @connection.run_query(query_to_run, "xquery")
      raise Exception.new("Invalid response: #{response.code.to_i}: #{response.body}") if (response.code.to_i != 200)
      response.body.to_i
    end

    def paged_results
      refresh unless @query_run
      @cache
    end

    def next
      refresh unless @query_run

      return nil if @visited == @limit

      if @cache.length == 0
        if page < total_pages
          self.page = page + 1
          refresh
        end

        if @cache.length == 0
          return nil
        end
      end

      @visited = @visited + 1
      doc = @cache.shift

      # TODO: Move this server side
      if @fields
        @fields << :_id unless @fields.include?(:_id) || @fields.include?('_id')
        doc = @fields.each_with_object(doc.class.new) { |key, result| result[key] = doc[key.to_s] if doc.has_key?(key.to_s) }
      end

      if @transformer.nil?
        doc
      else
        @transformer.call(doc) if doc
      end
    end
    alias_method :next_document, :next

    def convert_fields_for_query(fields)
      case fields
        when String, Symbol
          [ fields ]
        when Array
          return nil if fields.length.zero?
          fields
        when Hash
          return fields.keys
      end
    end

    def each(&block)
      while doc = self.next
        yield doc
      end
    end

    def to_a
      super
    end

    def rewind!
      self.page = 1
      @query_run = false
      @visited = 0
    end

    private

    def start
      if @options[:skip]
        @options[:skip] + 1
      else
        (page - 1) * page_length + 1
      end
    end

    def page
      page = @options[:page] || 1
      page.to_i
    end

    def page=(page)
      @options[:page] = page.to_i
    end

    def page_length
      @options[:per_page] || DEFAULT_PAGE_LENGTH
    end

    def total_pages
      (count.to_f / page_length.to_f).ceil
    end

    def view
      "none"
    end

    def format
      @options[:format] || "json"
    end

    def collection
      @collection
    end

    def return_results
      @options[:return_results] || false
    end

    def return_metrics
      @options[:return_metrics] || false
    end

    def return_qtext
      @options[:return_qtext] || false
    end

    def return_query
      @options[:return_query] || true
    end

    def debug
      @options[:debug] || false
    end

    def has_sort?
      @options.has_key?(:sort) || @options.has_key?(:order)
    end

    def query
      @query || MarkLogic::Queries::AndQuery.new
    end

    def sort
      return nil unless has_sort?

      sorters = @options[:sort] || @options[:order]
      sorters = [sorters] unless sorters.instance_of?(Array)

      sorters.map do |sorter|
        name = sorter[0].to_s
        direction = (sorter[1] && (sorter[1] == -1)) ? "descending" : "ascending"


        if @collection.database.has_range_index?(name)
          index = @collection.database.range_index(name)
          type = %Q{xs:#{index.scalar_type}}
          collation = index.collation
        else
          raise MissingIndexError.new("Missing index on #{name}")
        end
        {
          "direction" => direction || "ascending",
          "type" => type,
          "collation" => collation || "",
          "json-property" => name
        }
      end
    end

    def sort_xqy
      return %Q{cts:unordered()} unless has_sort?

      sorters = @options[:sort] || @options[:order]
      sorters = [sorters] unless sorters.instance_of?(Array)

      sorters.map do |sorter|
        name = sorter[0].to_s
        direction = (sorter[1] && (sorter[1] == -1)) ? "descending" : "ascending"

        unless @collection.database.has_range_index?(name)
          raise MissingIndexError.new("Missing index on #{name}")
        end

        ref = @collection.database.range_index(name).to_ref

        %Q{cts:index-order(#{ref}, "#{direction}")}
      end.join(',')
    end

    def refresh
      results = exec.body
      if results.nil?
        results = []
      else
        results = [results] unless results.instance_of?(Array)
      end
      @cache = results
    end

    def exec
      query = to_xqy
      response = @connection.run_query(query, "xquery")
      raise Exception.new("Invalid response: #{response.code.to_i}: #{response.body}") if (response.code.to_i != 200)

      @query_run = true
      response
    end

    def to_xqy
      start_index = start
      end_index = start_index + page_length - 1
      col_name = collection.nil? ? "" : %Q{"#{collection.collection}"}
      %Q{(cts:search(fn:collection(#{col_name}), #{query.to_xqy}, ("unfiltered", "score-zero", #{sort_xqy})))[#{start_index} to #{end_index}]}
    end
  end
end
