$:.unshift(File.expand_path('../../lib', __FILE__))

require 'rubygems'
require 'bundler'

require 'marklogic'

require 'pp'
require 'pry'

srand RSpec.configuration.seed

# These environment variables can be set if wanting to test against a database
# that is not on the local machine.
ENV["MARKLOGIC_SPEC_HOST"] ||= "localhost"
ENV["MARKLOGIC_SPEC_PORT"] ||= "8011"
ENV["MARKLOGIC_SPEC_APP_SERVICES_PORT"] ||= "8000"
ENV["MARKLOGIC_SPEC_ADMIN_PORT"] ||= "8001"
ENV["MARKLOGIC_SPEC_MANAGE_PORT"] ||= "8002"
ENV["MARKLOGIC_SPEC_ADMIN_USER"] ||= "admin"
ENV["MARKLOGIC_SPEC_ADMIN_PASSWORD"] ||= "admin"

# These are used when creating any connection in the test suite.
HOST = ENV["MARKLOGIC_SPEC_HOST"]
PORT = ENV["MARKLOGIC_SPEC_PORT"].to_i

APP_SERVICES_PORT = ENV["MARKLOGIC_SPEC_APP_SERVICES_PORT"]
MANAGE_PORT = ENV["MARKLOGIC_SPEC_MANAGE_PORT"]
ADMIN_PORT = ENV["MARKLOGIC_SPEC_ADMIN_PORT"]
ADMIN_USER = ENV["MARKLOGIC_SPEC_ADMIN_USER"]
ADMIN_PASSWORD = ENV["MARKLOGIC_SPEC_ADMIN_PASSWORD"]

MarkLogic::Connection.configure({
  :host => HOST,
  :manage_port => MANAGE_PORT,
  :admin_port => ADMIN_PORT,
  :app_services_port => APP_SERVICES_PORT,
  :default_user => ADMIN_USER,
  :default_password => ADMIN_PASSWORD
})

CONNECTION = MarkLogic::Connection.new(HOST, PORT)

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.fail_fast = true
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.before(:all) do
    @application = MarkLogic::Application.new("marklogic-gem-application-test", connection: CONNECTION).tap do |app|
      app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:age, :type => 'int'))
      app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:weight, :type => 'int'))
    end
    @application.sync
    @database = @application.content_databases[0]
    @database.clear
  end

  config.after(:suite) do
    puts "CLEANING UP AFTER ALL TESTS FINISHED"
    manage_connection = MarkLogic::Connection.manage_connection
    admin_connection = MarkLogic::Connection.admin_connection
    options = { :connection => manage_connection, :port => PORT, :admin_connection => admin_connection }
    MarkLogic::Application.new("marklogic-gem-application-test", options).drop
  end
end
