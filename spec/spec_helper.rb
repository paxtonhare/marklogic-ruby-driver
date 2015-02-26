$:.unshift(File.expand_path('../../lib', __FILE__))

require 'rubygems'
require 'bundler'

# Bundler.require(:default, :test)

require 'marklogic'

require 'fileutils'
require 'logger'
require 'pp'
require 'pry'
# require 'log_buddy'

# log_dir = File.expand_path('../../log', __FILE__)
# FileUtils.mkdir_p(log_dir)
# Log = Logger.new(File.join(log_dir, 'test.log'))

# LogBuddy.init :logger => Log

# These environment variables can be set if wanting to test against a database
# that is not on the local machine.
ENV["MARKLOGIC_SPEC_HOST"] ||= "localhost"
ENV["MARKLOGIC_SPEC_PORT"] ||= "8011"
ENV["MARKLOGIC_SPEC_USER"] ||= "admin"
ENV["MARKLOGIC_SPEC_PASSWORD"] ||= "admin"
ENV["MARKLOGIC_SPEC_APP_SERVICES_PORT"] ||= "8000"
ENV["MARKLOGIC_SPEC_ADMIN_PORT"] ||= "8001"
ENV["MARKLOGIC_SPEC_MANAGE_PORT"] ||= "8002"
ENV["MARKLOGIC_SPEC_ADMIN_USER"] ||= "admin"
ENV["MARKLOGIC_SPEC_ADMIN_PASSWORD"] ||= "admin"

# These are used when creating any connection in the test suite.
HOST = ENV["MARKLOGIC_SPEC_HOST"]
PORT = ENV["MARKLOGIC_SPEC_PORT"].to_i
USER = ENV["MARKLOGIC_SPEC_USER"]
PASSWORD = ENV["MARKLOGIC_SPEC_PASSWORD"]

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
  # config.filter_run_excluding :working => true
  # config.alias_example_to :fit, :focused => true
  # config.alias_example_to :xit, :pending => true
  config.run_all_when_everything_filtered = true
  config.fail_fast = true
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  # config.before(:suite) do
  #   DB.collections.reject { |collection|
  #     collection.name =~ /system\./
  #   }.map(&:drop_indexes)
  # end

  # config.before(:each) do
  #   DB.collections.reject { |collection|
  #     collection.name =~ /system\./
  #   }.map(&:remove)
  # end

  config.after(:suite) do
    puts "CLEANING UP AFTER ALL TESTS FINISHED"
    manage_connection = MarkLogic::Connection.manage_connection
    admin_connection = MarkLogic::Connection.admin_connection
    options = { :connection => manage_connection, :port => PORT, :admin_connection => admin_connection }
    MarkLogic::Application.new("marklogic-gem-application-test", options).drop
  end
end
