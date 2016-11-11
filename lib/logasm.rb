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

  def debug(*args, &block)
    log :debug, *args, &block
  end

  def info(*args, &block)
    log :info, *args, &block
  end

  def warn(*args, &block)
    log :warn, *args, &block
  end

  def error(*args, &block)
    log :error, *args, &block
  end

  def fatal(*args, &block)
    log :fatal, *args, &block
  end

  LOG_LEVEL_QUERY_METHODS.each do |method|
    define_method(method) do
      @adapters.any? {|adapter| adapter.public_send(method) }
    end
  end

  private

  def log(level, *args, &block)
    data = parse_log_data(*args, &block)
    processed_data = preprocess(data)

    @adapters.each do |adapter|
      adapter.log(level, processed_data)
    end
  end

  def preprocess(data)
    @preprocessors.inject(data) do |data_to_process, preprocessor|
      preprocessor.process(data_to_process)
    end
  end

  def parse_log_data(message = nil, metadata = {}, &block)
    return message if message.is_a?(Hash)

    (metadata || {}).merge(message: block ? block.call : message)
  end
end
