require 'socket'
require 'logstash-event'
require_relative 'logstash_adapter/formatter'

class Logasm
  module Adapters
    class LogstashAdapter
      attr_reader :logger

      def initialize(level, service, arguments = {})
        host = arguments.fetch(:host)
        port = arguments.fetch(:port)
        device = UDPSocket.new.tap do |socket|
          socket.connect(host, port)
        end

        @logger = Logger.new(device).tap do |logger|
          logger.formatter = Formatter.new(service)
          logger.level = level
        end
      end

      def log(level, data)
        @logger.public_send level, data
      end
    end
  end
end
