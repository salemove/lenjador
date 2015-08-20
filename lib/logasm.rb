require 'inflecto'
require 'logger'
require_relative 'logasm/adapters'
require_relative 'logasm/adapters/stdout_adapter'
require_relative 'logasm/adapters/logstash_adapter'
require_relative 'logasm/adapters/rabbitmq_adapter'

class Logasm
  def self.build(service_name, loggers_config)
    loggers_config ||= {stdout: nil}
    adapters = loggers_config.map do |type, arguments|
      Adapters.get(type.to_s, service_name, arguments || {})
    end
    new(adapters)
  end

  def initialize(adapters)
    @adapters = adapters
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

  def log(level, *args)
    data = parse_log_data(*args)

    @adapters.each do |adapter|
      adapter.log(level, data)
    end
  end

  def parse_log_data(message, metadata = {})
    return message if message.is_a?(Hash)

    (metadata || {}).merge(message: message)
  end
end
