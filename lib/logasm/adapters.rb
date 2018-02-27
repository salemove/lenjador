class Logasm
  module Adapters
    LOG_LEVELS = %w(debug info warn error fatal unknown).freeze

    def self.get(type, service_name, arguments)
      adapter =
        if type == 'stdout'
          if arguments.fetch(:json, false)
            require_relative 'adapters/stdout_json_adapter'
            StdoutJsonAdapter
          else
            require_relative 'adapters/stdout_adapter'
            StdoutAdapter
          end
        else
          raise "Unsupported logger: #{type}"
        end
      level = LOG_LEVELS.index(arguments.fetch(:level, 'debug'))
      adapter.new(level, service_name, arguments)
    end
  end
end
