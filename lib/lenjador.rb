# frozen_string_literal: true

require 'logger'
require_relative 'lenjador/adapters'
require_relative 'lenjador/utils'
require_relative 'lenjador/null_logger'
require_relative 'lenjador/preprocessors'

class Lenjador
  Severity = ::Logger::Severity
  SEV_LABEL = %w[debug info warn error fatal any].freeze

  def self.build(service_name, logger_config, preprocessors_config = {})
    logger_config ||= {}

    preprocessors = preprocessors_config.map do |type, arguments|
      Preprocessors.get(type.to_s, arguments || {})
    end
    adapter = Adapters.get(service_name, logger_config)
    level = SEV_LABEL.index(logger_config.fetch(:level, 'debug'))

    new(adapter, level, preprocessors)
  end

  def initialize(adapter, level, preprocessors)
    @adapter = adapter
    @level = level
    @preprocessors = preprocessors
  end

  def add(severity, *args, &block)
    log(severity, *args, &block)
  end

  def debug(*args, &block)
    log(Severity::DEBUG, *args, &block)
  end

  def info(*args, &block)
    log(Severity::INFO, *args, &block)
  end

  def warn(*args, &block)
    log(Severity::WARN, *args, &block)
  end

  def error(*args, &block)
    log(Severity::ERROR, *args, &block)
  end

  def fatal(*args, &block)
    log(Severity::FATAL, *args, &block)
  end

  def debug?; @level <= Severity::DEBUG; end

  def info?; @level <= Severity::INFO; end

  def warn?; @level <= Severity::WARN; end

  def error?; @level <= Severity::ERROR; end

  def fatal?; @level <= Severity::FATAL; end

  def level=(new_level)
    raise ArgumentError, "invalid log level: #{new_level}" unless new_level.is_a?(Integer)

    @level = new_level
  end

  private

  def log(level, *args, &block)
    return true if level < @level

    data = parse_log_data(*args, &block)
    processed_data = preprocess(data)

    @adapter.log(level, processed_data)
  end

  def preprocess(data)
    @preprocessors.inject(data) do |data_to_process, preprocessor|
      preprocessor.process(data_to_process)
    end
  end

  def parse_log_data(message = nil, metadata = {}, &block)
    return message if message.is_a?(Hash)

    (metadata || {}).merge(message: block ? yield : message)
  end
end
