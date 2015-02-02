class Logasm
  module Adapters
    class LogstashAdapter
      class Formatter < ::Logger::Formatter
        HOST = ::Socket.gethostname

        def initialize(service_name)
          @service_name = service_name
        end

        def call(severity, time, _progname, message)
          event = build_event(message, severity, time)
          "#{event.to_json}\n"
        end

        private

        def build_event(metadata, level, time)
          event = LogStash::Event.new(metadata.merge("@timestamp" => time))

          event['application'] = @service_name if @service_name
          event['level'] = level.downcase
          event['host'] ||= HOST

          # In case Time#to_json has been overridden
          if event.timestamp.is_a?(Time)
            event.timestamp = event.timestamp.iso8601(3)
          end

          event
        end
      end
    end
  end
end
