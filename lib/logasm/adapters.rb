class Logasm
  module Adapters
    LOG_LEVELS = %w(debug info warn error fatal unknown).freeze

    def self.get(type, service_name, arguments)
      adapter = const_get(Inflecto.camelize(type.to_s) + 'Adapter')
      level = LOG_LEVELS.index(arguments.fetch(:level, 'debug'))
      adapter.new(level, service_name, arguments)
    end
  end
end
