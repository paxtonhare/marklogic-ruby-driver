require 'pp'

module MarkLogic
  class Database
    include MarkLogic::Persistence

    INDEX_KEYS = [
      'range-element-index',
      'element-word-lexicon',
      'element-attribute-word-lexicon',
      # 'path-namespace',
      # 'field',
      'range-path-index',
      'range-field-index',
      'geospatial-element-index',
      'geospatial-element-child-index',
      'geospatial-element-pair-index',
      'geospatial-path-index'
    ]

    attr_accessor :database_name, :application
    def initialize(database_name, conn = nil)
      self.connection = conn

      @database_name = database_name
      @options = {
        "database-name" => @database_name,
        "collection-lexicon" => true
      }

      reset_indexes
    end

    def self.load(database_name, conn = nil)
      db = Database.new(database_name, conn)
      db.load
      db
    end

    def load
      resp = manage_connection.get(%Q{/manage/v2/databases/#{database_name}/properties?format=json})
      if resp.code.to_i == 200
        options = Oj.load(resp.body)
        options.each do |key, value|
          self[key] = value
        end
      end
    end

    def inspect
      as_nice_string = @options.collect do |key, value|
        " #{key}: #{value.inspect}"
      end.sort.join(",")
      "#<#{self.class}#{as_nice_string}>"
    end

    def []=(key, value)
      @options[key] = value
    end

    def [](key)
      @options[key]
    end

    def has_key?(key)
      @options.has_key?(key)
    end

    # def add_database_backup()
    #   @options["database-backups"] <<
    # end

    # def add_fragment_root()
    #   # @options["fragment-roots"] <<
    # end

    # def add_fragment_parent()
    #   # @options["fragment-parents"] <<
    # end

    # def add_element_word_query_through()
    #   # @options["element-word-query-throughs"] <<
    # end

    # def add_phrase_through()
    #   # @options["phrase-throughs"] <<
    # end

    def add_range_element_index(name, options = {})
      add_index "range-element-index", MarkLogic::DatabaseSettings::RangeElementIndex.new(name, options)
    end

    def add_element_word_lexicon(localname, options)
       add_index "element-word-lexicons", MarkLogic::DatabaseSettings::ElementWordLexicon.new(localname, options)
    end

    def add_path_namespace()
      # add_index "path-namespace"
    end

    def add_range_path_index(path_expression, options = {})
      add_index "range-path-index", MarkLogic::DatabaseSettings::RangePathIndex.new(path_expression, options)
    end

    def add_field()
      # add_index "fields"
    end

    def add_range_field_index(field_name, options = {})
      add_index "range-field-index", MarkLogic::DatabaseSettings::RangeFieldIndex.new(field_name, options)
    end

    def add_geospatial_element_index(element_name, latitude_localname, longitude_localname, options = {})
       add_index "geospatial-element-index", MarkLogic::DatabaseSettings::GeospatialElementIndex.new(element_name, latitude_localname, longitude_localname, options)
    end

    def add_geospatial_element_child_index(element_name, latitude_localname, longitude_localname, options = {})
      add_index "geospatial-element-child-index", MarkLogic::DatabaseSettings::GeospatialElementChildIndex.new(element_name, latitude_localname, longitude_localname, options)
    end

    def add_geospatial_element_pair_index(element_name, latitude_localname, longitude_localname, options = {})
      add_index "geospatial-element-pair-index", MarkLogic::DatabaseSettings::GeospatialElementPairIndex(element_name, latitude_localname, longitude_localname, options)
    end

    def add_geospatial_path_index(path_expression, latitude_localname, longitude_localname, options = {})
      add_index "geospatial-path-index", MarkLogic::DatabaseSettings::GeospatialPathIndex.new(path_expression, latitude_localname, longitude_localname, options)
    end

    # def add_foreign_database()
    #   add_index "foreign-database"
    # end

    def create
      r = manage_connection.post_json(
        %Q{/manage/v2/databases?format=json},
        to_json)
    end

    def exists?
      manage_connection.head(%Q{/manage/v2/databases/#{database_name}}).code.to_i  == 200
    end

    def stale?
      response = manage_connection.get(%Q{/manage/v2/databases/#{database_name}/properties?format=json})
      raise Exception.new("Invalid response: #{response.code.to_i}: #{response.body}") if (response.code.to_i != 200)

      props = Oj.load(response.body)

      INDEX_KEYS.each do |key|
        if props[key]
          local = @options[key].uniq.sort
          remote = props[key].map { |json| MarkLogic::DatabaseSettings::Index.from_json(key, json) }.uniq.sort
          unless local == remote
            logger.debug "#{database_name}: #{local} != #{remote}"
            return true
          end
        elsif @options.has_key?(key) && @options[key] != []
          logger.debug "#{database_name}: #{key} is not on the remote end"
          return true
        end
      end

      return false
    end

    def drop
      r = manage_connection.delete(%Q{/manage/v2/databases/#{database_name}?format=json})
    end

    def to_json
      json = {}
      @options.each do |k, v|
        if v.kind_of?(Array)
          value = v.map { |item| item.to_json }
        else
          value = v
        end
        json[k] = value
      end
      # puts json
      json
    end

    def update
      url = %Q{/manage/v2/databases/#{database_name}/properties?format=json}
      r = manage_connection.put(url, JSON.generate(to_json))
    end

    def reset_indexes
      INDEX_KEYS.each do |key|
        @options[key] = []
       end
    end

    def add_index(index_type, index)
      @options[index_type] = [] unless @options[index_type]
      @options[index_type] << index
      @options[index_type].uniq! { |ii| ii.key }
      application.add_index(index) if application
    end

    def range_index(name)
      @options["range-element-index"].each do |index|
        return index if index.localname == name
      end
    end

    def has_range_index?(name)
      @options["range-element-index"].each do |index|
        return true if index.localname == name
      end

      return false
    end

    def collection(name)
      MarkLogic::Collection.new(name, self)
    end

    def clear
      r = connection.delete(%Q{/v1/search})
    end

    def collections()
      res = connection.run_query('cts:collections()', "xquery")
      if res.code.to_i == 200
        return res.body || []
      else
        raise MissingCollectionLexiconError.new if res.body =~ /XDMP-COLLXCNNOTFOUND/
      end
    end
  end
end
