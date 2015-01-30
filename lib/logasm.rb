require 'logstash-logger'
require_relative 'adapters/standard_logger_adapter'
require_relative 'adapters/logstash_adapter'

module Logasm
  class Logasm
    LOG_LEVELS = %w(debug info warn error fatal unknown).freeze

    attr_reader :loggers

    def initialize(loggers, service_name)
      @loggers = []
      @service_name = service_name

      if loggers == nil
        loggers = {file: nil}
      end

      loggers.each do |logger|
        logger_type = logger.first.to_s
        logger_arguments = logger[1] || {}
        @loggers.push create_logger(logger_type, logger_arguments)
      end
    end

    def debug(*args)
      log :debug, *args
    end

    def info(*args)
      log :info, *args
    end

    def warn(*args)
      log :warn, *args
    end

    def error(*args)
      log :error, *args
    end

    def fatal(*args)
      log :fatal, *args
    end

    private

    def create_logger(type, arguments)
      if type == 'file'
        level = get_log_level(arguments[:level]) || 0
        logger = Adapters::StandardLoggerAdapter.new(level)
      elsif type == 'logstash'
        level = get_log_level(arguments[:level]) || 1
        logger = Adapters::LogstashAdapter.new(level, @service_name, arguments)
      end
    end

    def get_log_level(level)
      LOG_LEVELS.index(level)
    end

    def log(level, *args)
      message, metadata = parse_log_data *args

      @loggers.each do |logger|
        begin
          logger.send :log, level, message.clone, metadata.clone
        rescue => e
          error "Logging using #{logger.class.to_s} failed: #{e.message}"
          error e.backtrace.join("\n")
        end
      end
    end

    def parse_log_data(*args)
      if args[0].is_a? String
        if args[1] 
          return args[0], args[1]
        else
          return args[0], {}
        end
      elsif args[0].is_a? Hash
        return nil, args[0]
      elsif args[0] == nil
        return nil, {}
      else
        error "Unable to log data: #{args}"
      end
    end
  end
end
