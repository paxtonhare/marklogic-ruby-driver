module MarkLogic
  class AppServer
    include MarkLogic::Persistence

    attr_accessor :server_name, :server_type, :group_name

    def initialize(server_name, port, server_type = "http", group_name = "Default", options = {})
      content_database = options[:content_database] || "#{server_name.gsub(/_/, "-")}-content"
      modules_database = options[:modules_database] || "#{server_name.gsub(/_/, "-")}-modules"
      self.connection = options[:connection]
      self.admin_connection = options[:admin_connection]

      @server_name = server_name
      @server_type = server_type
      @group_name = group_name

      @options = {
        "server-name" => @server_name,
        "root" => options[:root] || "/",
        "port" => port,
        "content-database" => content_database,
        "modules-database" => modules_database,
        "url-rewriter" => "/MarkLogic/rest-api/rewriter.xml",
        "error-handler" => "/MarkLogic/rest-api/error-handler.xqy",
        "rewrite-resolves-globally" => true
      }
    end

    def self.load(server_name, group_name = "Default")
      app_server = AppServer.new(server_name, 0, 'http', group_name)
      app_server.load
      app_server
    end

    def load
      resp = manage_connection.get(%Q{/manage/v2/servers/#{server_name}/properties?group-id=#{group_name}&format=json})
      if resp.code.to_i == 200
        options = Oj.load(resp.body)
        options.each do |key, value|
          self[key] = value
        end
      end
    end

    def inspect
      as_nice_string = [
        "server_name: #{server_name}",
        "server_type: #{server_type}",
        "port: #{self['port']}"
      ].join(",")
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

    def create
      r = manage_connection.post_json(
        %Q{/manage/v2/servers/?group-id=#{group_name}&server-type=#{server_type}&format=json},
        @options)
    end

    def drop
      r = manage_connection.delete(%Q{/manage/v2/servers/#{server_name}?group-id=#{group_name}&format=json})

      # wait for restart
      admin_connection.wait_for_restart(r.body) if r.code.to_i == 202

      return r
    end

    def exists?
      manage_connection.head(%Q{/manage/v2/servers/#{server_name}?group-id=#{group_name}}).code.to_i == 200
    end
  end
end
