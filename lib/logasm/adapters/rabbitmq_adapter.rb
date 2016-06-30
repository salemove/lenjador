begin
  require 'freddy'
rescue LoadError => e
  raise unless e.message =~ /freddy/
  exception = e.exception('To use RabbitMQ adapter for logging, please install freddy!')
  exception.set_backtrace(e.backtrace)
  raise exception
end

class Logasm
  module Adapters
    class RabbitmqAdapter
      attr_reader :freddy

      CONFIGURATION_KEYS = [:host, :user, :pass, :port]

      def initialize(level, service_name, arguments = {})
        config = arguments.select { |key, value| CONFIGURATION_KEYS.include?(key) }
        logger = NullLogger.new
        @queue = arguments.fetch(:queue, 'logstash-queue')
        @level = level
        @service_name = service_name
        @freddy = Freddy.build(logger, config.merge({recover_from_connection_close: true}))
      end

      def log(level, metadata = {})
        if meets_threshold?(level)
          message = Utils.build_event(metadata, level, @service_name)
          deliver_message message
        end
      end

      def debug?
        meets_threshold?(:debug)
      end

      def info?
        meets_threshold?(:info)
      end

      def warn?
        meets_threshold?(:warn)
      end

      def error?
        meets_threshold?(:error)
      end

      def fatal?
        meets_threshold?(:fatal)
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
