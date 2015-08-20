require 'socket'

class Logasm
  module Adapters
    class RabbitmqAdapter
      class MessageBuilder
        HOST = ::Socket.gethostname

        def initialize(service_name)
          @service_name = service_name
        end

        def build_message(metadata, level)
          attributes = { application: @service_name,
                         level: level,
                         host: HOST,
                         :@timestamp => Time.now.utc.iso8601(3) }

          metadata.merge attributes
        end
      end
    end
  end
end
