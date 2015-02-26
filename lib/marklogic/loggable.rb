module MarkLogic
  module Loggable
    def logger
      @logger ||= (rails_logger || default_logger)
    end

    # Get the rails logger.
    #
    # @example Get the rails logger.
    #   Logging.rails_logger
    #
    # @return [ Logger ] The Rails logger.
    #
    # @since 1.0.0
    def rails_logger
      Rails.logger if defined?(Rails) && Rails.respond_to?(:logger)
    end

    # Get the default logger.
    #
    # @example Get the default logger.
    #   Logging.default_logger
    #
    # @return [ Logger ] The default logger.
    #
    # @since 1.0.0
    def default_logger
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG
      logger
    end

    # Set the logger.
    #
    # @example Set the logger.
    #   Logging.logger = logger
    #
    # @return [ Logger ] The logger.
    #
    # @since 1.0.0
    def logger=(logger)
      @logger = logger
    end
  end
  extend Loggable
end
