require_relative 'logstash_logger/formatter'
require_relative 'logstash_logger/logger'

module Logasm
  module Adapters
    class LogstashAdapter
      def initialize(level, service, arguments)
        @logger = LogStashLogger.new(service,
                                    type: :udp,
                                    host: arguments[:host],
                                    port: arguments[:port])
        @logger.level = level
        @logger
      end

      def log(level, message = nil, metadata = {})
        @logger.send level, build_message(message, metadata)
      end

      private

      def build_message(message, metadata)
        metadata[:message] = message if message
        "#{metadata.to_json}"
      end
    end
  end
end