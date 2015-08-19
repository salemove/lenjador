require_relative 'rabbitmq_adapter/message_builder'
require_relative 'rabbitmq_adapter/publisher'

class Logasm
  module Adapters
    class RabbitmqAdapter
      attr_reader :publisher

      CONFIGURATION_KEYS = [:host, :user, :pass, :port]

      def initialize(level, service, arguments = {})
        config = arguments.select { |key, value| CONFIGURATION_KEYS.include?(key) }
        queue = arguments.fetch(:queue, 'logstash-queue')
        @level = level
        @message_builder = MessageBuilder.new(service)

        @publisher = Publisher.new(queue, config)
      end

      def log(level, metadata = {})
        if meets_threshold?(level)
          message = @message_builder.build_message metadata, level
          @publisher.publish message
        end
      end

      private

      def meets_threshold?(level)
        LOG_LEVELS.index(level.to_s) >= @level
      end
    end
  end
end
