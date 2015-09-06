class Logasm
  module Adapters
    class LogstashAdapter
      class Formatter < ::Logger::Formatter
        def initialize(service_name)
          @service_name = service_name
        end

        def call(level, _time, _progname, message)
          event = Utils.build_event(message, level, @service_name)
          "#{event.to_json}\n"
        end
      end
    end
  end
end
