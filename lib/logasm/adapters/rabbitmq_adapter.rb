begin
  require 'bunny'
rescue LoadError => e
  raise unless e.message =~ /bunny/
  exception = e.exception('To use RabbitMQ adapter for logging, please install bunny!')
  exception.set_backtrace(e.backtrace)
  raise exception
end

class Logasm
  module Adapters
    class RabbitmqAdapter
      CONFIGURATION_KEYS = [:host, :hosts, :user, :pass, :port]

      attr_reader :bunny

      def initialize(level, service_name, arguments = {})
        config = arguments.select { |key, value| CONFIGURATION_KEYS.include?(key) }
        @level = level
        @service_name = service_name
        @bunny = Bunny.new(config)
        @queue_name = arguments.fetch(:queue, 'logstash-queue')
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
        queue.publish JSON.dump(message)
      rescue Bunny::ConnectionClosedError
      end

      def queue
        @queue ||= begin
          bunny.start
          channel = bunny.create_channel
          channel.queue(@queue_name)
        end
      end
    end
  end
end
