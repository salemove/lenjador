begin
  require 'freddy'
rescue LoadError => e
  raise unless e.message =~ /freddy/
  exception = e.exception('To use RabbitMQ adapter for logging, please install freddy!')
  exception.set_backtrace(e.backtrace)
  raise exception
end

require_relative 'rabbitmq_adapter/message_builder'

class Logasm
  module Adapters
    class RabbitmqAdapter
      attr_reader :freddy

      CONFIGURATION_KEYS = [:host, :user, :pass, :port]

      def initialize(level, service, arguments = {})
        config = arguments.select { |key, value| CONFIGURATION_KEYS.include?(key) }
        logger = Logger.new(STDOUT)
        @queue = arguments.fetch(:queue, 'logstash-queue')
        @level = level
        @message_builder = MessageBuilder.new(service)
        @freddy = Freddy.build(logger, config.merge({recover_from_connection_close: true}))
      end

      def log(level, metadata = {})
        if meets_threshold?(level)
          message = @message_builder.build_message metadata, level
          deliver_message message
        end
      end

      private

      def meets_threshold?(level)
        LOG_LEVELS.index(level.to_s) >= @level
      end

      def deliver_message(message)
        @freddy.deliver @queue, message
      rescue Bunny::ConnectionClosedError
      end
    end
  end
end
