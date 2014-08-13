require 'logstash-logger'

Dir[File.expand_path('logstash_override/*.rb', File.dirname(__FILE__))].each {|f| require f }

class Logasm
  def initialize(loggers, service_name)
    @loggers = []
    @service_name = service_name
    loggers.each do |logger|
      logger_type = logger.first.to_s
      logger_arguments = logger[1]
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

  def create_logger(type, arguments = nil)
    if type == 'file'
      Logger.new(STDOUT)
    elsif type == 'logstash'
      LogStashLogger.new(@service_name,
                         type: :udp,
                         host: arguments[:host],
                         port: arguments[:port])
    elsif type == 'loggly'
      Logglier.new('https://logs.loggly.com/inputs/#{arguments[:id]}',
                   :format => :json)
    end
  end
end
