require 'socket'
require_relative 'logstash_adapter/formatter'
require 'forwardable'

class Logasm
  module Adapters
    class LogstashAdapter
      extend Forwardable
      attr_reader :logger

      def_delegators :@logger, :debug?, :info?, :warn?, :error?, :fatal?

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
