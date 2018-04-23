module Sp2db
  module Logging

    extend self

    # @!attribute [rw] logger
    # @return [Logger] The logger.
    def logger
      @logger ||= get_logger
    end

    # @return [Logger]
    def logger= l
      @logger = l
    end

    # @return [Logger]
    def get_logger
      if  defined?(::Rails) && ::Rails.respond_to?(:logger) && !::Rails.logger.nil?
        ::Rails.logger
      else
        logger = Logger.new($stdout)
        logger.level = Logger::WARN
        logger
      end
    end

  end
end
