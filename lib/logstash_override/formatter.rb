module LogStashLogger
  class Formatter < ::Logger::Formatter
    include TaggedLogging::Formatter

    def initialize(service_name)
      @service_name = service_name
    end

    def call(severity, time, progname, message)
      event = build_event(message, severity, time)
      "#{event.to_json}\n"
    end

    protected

    def build_event(message, severity, time)
      data = message
      json = data.scan(/(\{.*\})/).first
      data = json.first if json

      if data.is_a?(String) && data.start_with?('{')
        data = (JSON.parse(data) rescue nil) || data
        data['unparsed'] = message
      end

      event = case data
                when LogStash::Event
                  data.clone
                when Hash
                  event_data = data.merge("@timestamp" => time)
                  LogStash::Event.new(event_data)
                when String
                  LogStash::Event.new("message" => data, "@timestamp" => time)
              end

      event['application'] = @service_name if @service_name

      event['severity'] ||= severity
      #event.type = progname

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
  end
end
