require 'inflecto'
require 'logger'
require 'json'
require_relative 'logasm/adapters'
require_relative 'logasm/utils'
require_relative 'logasm/null_logger'
require_relative 'logasm/preprocessors'

LOG_LEVEL_QUERY_METHODS = [:debug?, :info?, :warn?, :error?, :fatal?]

class Logasm
  def self.build(service_name, loggers_config, preprocessors_config = {})
    loggers_config ||= {stdout: nil}
    preprocessors = preprocessors_config.map do |type, arguments|
      Preprocessors.get(type.to_s, arguments || {})
    end
    adapters = loggers_config.map do |type, arguments|
      Adapters.get(type.to_s, service_name, arguments || {})
    end
    new(adapters, preprocessors)
  end

  def initialize(adapters, preprocessors)
    @adapters = adapters
    @preprocessors = preprocessors
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

  def method_missing(method, *args)
    if LOG_LEVEL_QUERY_METHODS.include?(method)
      @adapters.any? {|adapter| adapter.public_send(method) }
    else
      super
    end
  end

  private

  def log(level, *args)
    data = parse_log_data(*args)

    preprocess(data)

    @adapters.each do |adapter|
      adapter.log(level, data)
    end
  end

  def preprocess(data)
    @preprocessors.inject(data) do |data_to_process, preprocessor|
      preprocessor.process(data_to_process)
    end
  end

  def parse_log_data(message, metadata = {})
    return message if message.is_a?(Hash)

    (metadata || {}).merge(message: message)
  end
end
