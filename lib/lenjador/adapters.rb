# frozen_string_literal: true

class Lenjador
  module Adapters
    LOG_LEVELS = %i[debug info warn error fatal unknown].freeze

    def self.get(type, service_name, arguments)
      raise "Unsupported logger: #{type}" if type != 'stdout'

      adapter =
        if arguments.fetch(:json, false)
          require_relative 'adapters/stdout_json_adapter'
          StdoutJsonAdapter
        else
          require_relative 'adapters/stdout_adapter'
          StdoutAdapter
        end
      level = LOG_LEVELS.index(arguments.fetch(:level, :debug).to_sym)
      adapter.new(level, service_name, arguments)
    end
  end
end
