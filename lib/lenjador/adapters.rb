# frozen_string_literal: true

class Lenjador
  module Adapters
    def self.get(service_name, config)
      adapter =
        if config.fetch(:json, false)
          require_relative 'adapters/stdout_json_adapter'
          StdoutJsonAdapter
        else
          require_relative 'adapters/stdout_adapter'
          StdoutAdapter
        end
      adapter.new(service_name)
    end
  end
end
