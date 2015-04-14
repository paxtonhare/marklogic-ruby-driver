require 'net/http'
require 'date'
require 'json'
require 'digest'

module Net
  module HTTPHeader
    @@nonce_count = -1
    CNONCE = Digest::MD5.hexdigest "%x" % (Time.now.to_i + rand(65535))

    def create_digest_auth(user, password, response)
      # based on http://segment7.net/projects/ruby/snippets/digest_auth.rb
      @@nonce_count += 1

      response['www-authenticate'] =~ /^(\w+) (.*)/

      params = {}
      $2.gsub(/(\w+)="(.*?)"/) { params[$1] = $2 }

      digest_auth(user, password, params)
    end

    def digest_auth(user, password, params)

      a_1 = "#{user}:#{params['realm']}:#{password}"
      a_2 = "#{@method}:#{@path}"
      request_digest = ''
      request_digest << Digest::MD5.new.update(a_1).hexdigest
      request_digest << ':' << params['nonce']
      request_digest << ':' << ('%08x' % @@nonce_count)
      request_digest << ':' << CNONCE
      request_digest << ':' << params['qop']
      request_digest << ':' << Digest::MD5.new.update(a_2).hexdigest

      header = []
      header << "Digest username=\"#{user}\""
      header << "realm=\"#{params['realm']}\""

      header << "qop=#{params['qop']}"

      header << "algorithm=MD5"
      header << "uri=\"#{@path}\""
      header << "nonce=\"#{params['nonce']}\""
      header << "nc=#{'%08x' % @@nonce_count}"
      header << "cnonce=\"#{CNONCE}\""
      header << "response=\"#{Digest::MD5.hexdigest(request_digest)}\""

      @header['Authorization'] = header
      params
    end

    def basic_auth(user, password)
      encoded = Base64.encode64("#{user}:#{password}").chomp

      @header['Authorization'] = ["Basic #{encoded}"]
    end
  end
end

module MarkLogic
  class Connection
    include MarkLogic::Loggable

    attr_accessor :admin, :manage, :app_services, :username, :password, :host, :port, :request_retries

    def self.configure(options = {})
      @@__host_name = options[:host] if options[:host]
      @@__app_services_port = options[:app_services_port] if options[:app_services_port]
      @@__admin_port = options[:admin_port] if options[:admin_port]
      @@__manage_port = options[:manage_port] if options[:manage_port]
      @@__default_user = options[:default_user] if options[:default_user]
      @@__default_password = options[:default_password] if options[:default_password]
    end

    def self.default_user
      @@__default_user ||= "admin"
    end

    def self.default_password
      @@__default_password ||= "admin"
    end

    def self.host_name
      @@__host_name ||= "localhost"
    end

    def self.app_services_port
      @@__app_services_port ||= 8000
    end

    def self.admin_port
      @@__admin_port ||= 8001
    end

    def self.manage_port
      @@__manage_port ||= 8002
    end

    def self.admin_connection(username = self.default_user, password = self.default_password)
      @@__admin_connection ||= Connection.new(self.host_name, self.admin_port, username, password)
    end

    def self.manage_connection(username = self.default_user, password = self.default_password)
      @@__manage_connection ||= Connection.new(self.host_name, self.manage_port, username, password)
    end

    def self.app_services_connection(username = self.default_user, password = self.default_password)
      @@__app_services_connection ||= Connection.new(self.host_name, self.app_services_port, username, password)
    end

    def host
      @host
    end

    def initialize(host, port, username = nil, password = nil, options = {})
      @host = host
      @port = port
      @username = username || self.class.default_user
      @password = password || self.class.default_password
      @request_retries = options[:request_retries] || 3
      @http = Net::HTTP.new(host, port)
    end

    def run_query(query, type = "javascript", options = {})
      params = {
        type.to_sym => query
      }
      params[:dbname] = options[:db] if options[:db]
      response = post('/eval', params)
        # :xquery => options[:query],
        # :locale => LOCALE,
        # :tzoffset => "-18000",
        # :dbname => options[:db]
    end

    def head(url, headers = {})
      request(url, 'head', headers)
    end

    def get(url, headers = {})
      request(url, 'get', headers)
    end

    def put(url, body = nil, headers = {})
      request(url, 'put', headers, body)
    end

    def post(url, params = nil, headers = {})
      request(url, 'post', headers, nil, params)
    end

    def post_json(url, params = nil, headers = {})
      request(url, 'post', headers, ::JSON.generate(params))
    end

    def post_multipart(url, body = nil, headers = {}, boundary = "BOUNDARY")
      headers['Content-Type'] = %Q{multipart/mixed; boundary=#{boundary}}
      headers['Accept'] = %Q{application/json}
      request(url, 'post', headers, body)
    end

    def delete(url, headers = {}, body = nil)
      request(url, 'delete', headers, body)
    end

    def wait_for_restart(body)
      json = JSON.parse(body)
      ts_value = json["restart"]["last-startup"][0]["value"]
      timestamp = DateTime.iso8601(ts_value).to_time
      new_timestamp = timestamp

      code = nil
      logger.debug "Waiting for restart"
      until code == 200 and new_timestamp > timestamp
        begin
          rr = get(%Q{/admin/v1/timestamp})
          code = rr.code.to_i
          bb = rr.body
          new_timestamp = DateTime.iso8601(bb).to_time if code == 200
        rescue
        end
      end
      logger.debug "Restart Complete"
    end

    def ==(other)
      @host == other.host &&
      @port == other.port &&
      @username == other.username &&
      @password == other.password
    end

    private

    def default_headers
      {
        'Connection' => 'keep-alive',
        'Keep-Alive' => '30',
        'User-Agent' => 'MarkLogic',
        'Content-type' => 'application/json'
      }
    end

    def split_multipart(response)
      if response.read_body
        body = response.body

        if body.length == 0
          response.body = nil
          return
        end

        content_type = response['Content-Type']
        if (content_type and content_type.match(/multipart\/mixed.*/))
          boundary = $1 if content_type =~ /^.*boundary=(.*)$/

          body.sub!(Regexp.new("[\r\n]+--#{boundary}--[\r\n]+$", Regexp::MULTILINE), "")
          body.sub!(Regexp.new("^[\r\n]+--#{boundary}.+?[\r\n]+", Regexp::MULTILINE), "")

          values = []
          body.split(Regexp.new(%Q{[\r\n]+--#{boundary}[\r\n]+}, Regexp::MULTILINE)).each do |item|
            splits = item.split(/\r\n\r\n/m)
            metas = splits[0]
            raw_value = splits[1]

            value_content_type = type = xpath = nil

            metas.split(/\r\n/m).each do |meta|
              if meta.match(/^Content-Type:.*/m)
                value_content_type = $1 if meta =~ /Content-Type:\s+(.*)$/
              elsif meta.match(/^X-Primitive:.*/)
                type = $1 if meta =~ /X-Primitive:\s+(.*)$/
              elsif meta.match(/^X-Path:.*/)
                xpath = $1 if meta =~ /X-Path:\s+(.*)$/
              end
            end

            if (value_content_type == "application/json") then
              value = JSON.parse(raw_value)
            else
              case type
              when "integer"
                value = raw_value.to_i
              when "boolean"
                value = raw_value == "true"
              when "decimal"
                value = raw_value.to_f
              else
                value = raw_value
              end
            end
            values.push(value)
          end

          if (values.length == 1)
            values = values[0]
          end
          output = values
        else
          output = body
        end
        response.body = output
      end
    end

    def request(url, verb = 'get', headers = {}, body = nil, params = nil)
      tries ||= request_retries

      logger.debug "Retry #{request_retries - tries} of #{request_retries} for:\n#{body}" unless (tries == request_retries)
      all_headers = {}

      # configure headers
      default_headers.merge(headers).each do |k, v|
        all_headers[k] = v
      end

      request = Net::HTTP.const_get(verb.capitalize).new(url, all_headers)

      # Send the auth info if we have it
      if @auth
        request.digest_auth(@username, @password, @auth)
      end

      request.set_form_data(params) if (params)
      request.body = body if (body)

      response = @http.request request

      if (response.code.to_i == 401 and @username and @password)
        auth_method = $1.downcase if response['www-authenticate'] =~ /^(\w+) (.*)/
        if (auth_method == "basic")
          request.basic_auth(@username, @password)
        elsif (auth_method == "digest")
          @auth = request.create_digest_auth(@username, @password, response)
        end

        response = @http.request request
      end

      # puts("#{response.code} : #{verb.upcase} => ://#{@host}:#{@port}#{url} :: #{body} #{params}")

      split_multipart(response)
      response
    rescue Net::ReadTimeout => e
      retry unless (tries -= 1).zero?
    end
  end
end
