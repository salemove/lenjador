require 'logstash-logger'
require_relative './logstash_override/formatter.rb'
require_relative './logstash_override/logger.rb'

class Logasm
  def initialize(loggers, service_name)
    @loggers = []
    @service_name = service_name

    if loggers == nil
      loggers = {file: nil}
    end

    loggers.each do |logger|
      logger_type = logger.first.to_s
      logger_arguments = logger[1] ? logger[1] : {}
      @loggers.push create_logger(logger_type, logger_arguments)
    end
  end

  def method_missing(m, *args, &block)
    @loggers.each do |logger|
      logger.send(m,*args)
    end
  end

  def loggers
    @loggers
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
    case level
    when 'debug'
      0
    when 'info'
      1
    when 'warn'
      2
    when 'error'
      3
    when 'fatal'
      4
    when 'unknown'
      5
    else
      nil
    end
  end
end
