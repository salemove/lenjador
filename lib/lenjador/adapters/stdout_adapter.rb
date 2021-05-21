# frozen_string_literal: true

require 'forwardable'

class Lenjador
  module Adapters
    class StdoutAdapter
      attr_reader :logger

      def initialize(_service_name)
        @logger = Logger.new($stdout)
      end

      def log(level, metadata = {})
        message = metadata[:message]
        data = metadata.reject { |key, _value| key == :message }
        log_data = [
          message,
          data.empty? ? nil : Utils.generate_json(data)
        ].compact.join(' ')

        @logger.add(level, log_data)
      end
    end
  end
end
