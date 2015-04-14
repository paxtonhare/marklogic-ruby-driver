module MarkLogic
  class Application
    include MarkLogic::Persistence

    attr_accessor :app_name

    def initialize(app_name, options = {})
      @app_name = app_name
      self.connection = options[:connection]
      @port = options[:port] || self.connection.port
      self.admin_connection = options[:admin_connection]
    end

    def create
      logger.debug(%Q{Creating Application: #{@app_name}})

      build_implicit_defs

      databases.each do |database_name, database|
        unless database.exists?
          database.create
        else
          database.update
        end
      end

      forests.each do |forest_name, forest|
        forest.create unless forest.exists?
      end

      app_servers.each do |server_name, app_server|
        app_server.create unless app_server.exists?
      end

    end

    def create_indexes
      build_implicit_defs

      content_databases.each do |database|
        if database.exists?
          database.update
        else
          database.create
        end
      end
    end

    def sync
      create if stale?
    end

    def sync!
      create
    end

    def drop
      logger.debug(%Q{Dropping Application: #{@app_name}})

      build_implicit_defs

      app_servers.each do |server_name, app_server|
        app_server.drop if app_server.exists?
      end

      databases.each do |database_name, database|
        if database.exists?
          database.drop
        end
      end

      forests.each do |forest_name, forest|
        if forest.exists?
          forest.drop
        end
      end
    end

    def exists?
      build_implicit_defs

      databases.each do |database_name, database|
        return false if !database.exists?
      end

      forests.each do |forest_name, forest|
        return false if !forest.exists?
      end

      app_servers.each do |server_name, app_server|
        return false if !app_server.exists?
      end

      return true
    end

    def stale?
      build_implicit_defs

      databases.each do |database_name, database|
        unless database.exists?
          logger.debug "database: #{database_name} is missing"
          return true
        end
      end

      content_databases.each do |database|
        if database.stale?
          logger.debug "database: #{database.database_name} is stale"
          return true
        end
      end

      forests.each do |forest_name, forest|
        unless forest.exists?
          logger.debug "forest: #{forest_name} is missing"
          return true
        end
      end

      app_servers.each do |server_name, app_server|
        unless app_server.exists?
          logger.debug "app_server: #{server_name} is missing"
          return true
        end
      end

      return false
    end

    def forests
      @forests ||= {}
    end

    def databases
      @databases ||= {}
    end

    def app_servers
      @app_servers ||= {}
    end

    def add_index(index)
      indexes[index.key] = index
    end

    def clear_indexes()
      content_databases.each do |database|
        database.reset_indexes
      end
      @indexes = {}
    end

    def content_databases
      app_servers.values.map do |app_server|
        databases[app_server['content-database']]
      end
    end

    def database(name)
      database = MarkLogic::Database.new(name)
      yield(database) if block_given?
      logger.info("#{__LINE__}: db_name: #{name}")
      databases[name] = database
    end

    def app_server(name)
      app_server = MarkLogic::AppServer.new(name, @port)
      yield(app_server) if block_given?
      app_servers[name] = app_server
    end

    private

    def indexes
      @indexes ||= {}
    end

    def build_implicit_defs
      build_appservers
      build_databases
      build_indexes
    end

    def build_appservers
      if app_servers.empty?
        app_servers[@app_name] = MarkLogic::AppServer.new(@app_name, @port, "http", "Default", :connection => self.connection, :admin_connection => admin_connection)
      end
    end

    def build_databases
      app_servers.each_value do |app_server|
        db_name = app_server['content-database']
        unless databases.has_key?(db_name)
          db = MarkLogic::Database.new(db_name, self.connection)
          db.application = self
          databases[db_name] = db
        end
        forests[db_name] = MarkLogic::Forest.new(db_name, nil, self.connection) unless forests.has_key?(db_name)
        forests[db_name].database = databases[db_name]

        modules_db_name = app_server['modules-database']
        unless databases.has_key?(modules_db_name)
          modules_db = MarkLogic::Database.new(modules_db_name, self.connection)
          modules_db.application = self
          databases[modules_db_name] = modules_db
        end
        forests[modules_db_name] = MarkLogic::Forest.new(modules_db_name, nil, self.connection) unless forests.has_key?(modules_db_name)
        forests[modules_db_name].database = databases[modules_db_name]
      end

      triggers_database = nil
      schema_database = nil
      databases.each_value do |database|
        if database.has_key?('triggers-database')
          logger.info "has triggers: [#{database['triggers-database']}]"
          triggers_database = database['triggers-database']
        end

        if database.has_key?('schema-database')
          schema_database = database['schema-database']
        end
      end

      if triggers_database and !databases.has_key?(triggers_database)
        databases[triggers_database] = MarkLogic::Database.new(triggers_database, self.connection)
      end

      if schema_database and !databases.has_key?(schema_database)
        databases[schema_database] = MarkLogic::Database.new(schema_database, self.connection)
      end
    end

    def build_indexes
      content_databases.each do |database|
        database.reset_indexes

        indexes.clone.each do |key, index|
          index.append_to_db(database)
        end
      end
    end
  end
end
