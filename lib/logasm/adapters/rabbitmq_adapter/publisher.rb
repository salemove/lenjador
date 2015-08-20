require 'bunny'

class Logasm
  module Adapters
    class RabbitmqAdapter
      class Publisher
        def initialize(queue, config)
          connection = Bunny.new("amqp://#{config[:user]}:#{config[:pass]}@#{config[:host]}:#{config[:port]}")
          connection.start
          @exchange = connection.create_channel.default_exchange
          @queue = queue
        end

        def publish(message)
          @exchange.publish(message.to_json, :routing_key => @queue)
        end
      end
    end
  end
end
