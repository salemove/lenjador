module LogStashLogger
  class Formatter < ::Logger::Formatter

    def initialize(service_name)
      @service_name = service_name
    end

    def call(severity, time, _progname, message)
      Event.new(message, severity, time).to_h(@service_name).to_json + "\n"
    end

    private

    class Event
      include TaggedLogging::Formatter

      def initialize(message, severity, time)
        @message = message
        @severity = severity
        @time = time
      end

      def to_h(service_name)
        data = parse_data
        event = build_event(data)

        event['application'] = service_name if service_name
        event['severity'] ||= @severity
        event['level'] = event['severity'].downcase
        event.remove("severity")

        event['host'] ||= HOST

        current_tags.each do |tag|
          event.tag(tag)
        end

        # In case Time#to_json has been overridden
        if event.timestamp.is_a?(Time)
          event.timestamp = event.timestamp.iso8601(3)
        end
        event
      end

      def parse_data
        data = @message
        if data.is_a?(String) && data.start_with?('{')
          data = (JSON.parse(@message) rescue nil) || @message
        end

        data
      end

      def build_event(data)
        case data
        when LogStash::Event
          data.clone
        when Hash
          event_data = data.merge("@timestamp" => @time)
          LogStash::Event.new(event_data)
        when String
          LogStash::Event.new("message" => data, "@timestamp" => @time)
        end
      end
    end
  end
end
