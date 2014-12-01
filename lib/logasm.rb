require 'logstash-logger'
require_relative 'logstash_override/formatter'
require_relative 'logstash_override/logger'

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

  def method_missing(*args)
    @loggers.each do |logger|
      begin
        logger.send(*args)
      rescue => e
        logger.error "Logging using #{logger.class.to_s} failed: #{e.message}"
        logger.error e.backtrace.join("\n")
      end
    end
  end

  private

  def create_logger(type, arguments)
    if type == 'file'
      logger = Logger.new(STDOUT)
      logger.level = get_log_level(arguments[:level]) || 0
      logger
    elsif type == 'logstash'
      logger = LogStashLogger.new(@service_name,
                                  type: :udp,
                                  host: arguments[:host],
                                  port: arguments[:port])
      logger.level = get_log_level(arguments[:level]) || 1
      logger
    elsif type == 'loggly'
      # Not implemented
      Logglier.new('https://logs.loggly.com/inputs/#{arguments[:id]}',
                   format: :json)
    end
  end

  def get_log_level(level)
    LOG_LEVELS.index(level)
  end
end
