require 'oj'
require 'active_support'
require 'active_support/core_ext/object'
require 'active_support/core_ext/string/inflections'
require "marklogic/version"
require "marklogic/consts"
require 'marklogic/queries'
require 'marklogic/exceptions'
require 'marklogic/object_id'

module MarkLogic
  autoload :Application, 'marklogic/application'
  autoload :AppServer, 'marklogic/app_server'
  autoload :Collection, 'marklogic/collection'
  autoload :Connection, 'marklogic/connection'
  autoload :Cursor, 'marklogic/cursor'
  autoload :Database, 'marklogic/database'
  autoload :DatabaseSettings, 'marklogic/database_settings'
  autoload :Forest, 'marklogic/forest'
  autoload :Loggable, 'marklogic/loggable'
  autoload :Persistence, 'marklogic/persistence'
end
