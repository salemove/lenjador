require 'time'

class Lenjador
  module Utils
    DECIMAL_FRACTION_OF_SECOND = 3
    NO_TRACE_INFORMATION = {}.freeze

    # Build logstash json compatible event
    #
    # @param [Hash] metadata
    # @param [#to_s] level
    # @param [String] service_name
    #
    # @return [Hash]
    def self.build_event(metadata, level, application_name)
      overwritable_params
        .merge(metadata)
        .merge(tracing_information)
        .merge(
          application: application_name,
          level: level
        )
    end

    # Return application name
    #
    # Returns lower snake case application name. This allows the
    # application value to be used in the elasticsearch index name.
    #
    # @param [String] service_name
    #
    # @return [String]
    def self.application_name(service_name)
      underscore(service_name)
    end

    def self.overwritable_params
      {
        :@timestamp => Time.now.utc.iso8601(DECIMAL_FRACTION_OF_SECOND)
      }
    end
    private_class_method :overwritable_params

    def self.serialize_time_objects!(object)
      if object.is_a?(Hash)
        object.each do |key, value|
          object[key] = serialize_time_objects!(value)
        end
      elsif object.is_a?(Array)
        object.each_index do |index|
          object[index] = serialize_time_objects!(object[index])
        end
      elsif object.is_a?(Time) || object.is_a?(Date)
        object.iso8601
      else
        object
      end
    end

    if RUBY_PLATFORM =~ /java/
      require 'jrjackson'

      DUMP_OPTIONS = {
        timezone: 'utc',
        date_format: "YYYY-MM-dd'T'HH:mm:ss.SSSX"
      }.freeze

      def self.generate_json(obj)
        JrJackson::Json.dump(obj, DUMP_OPTIONS)
      end
    else
      require 'oj'
      DUMP_OPTIONS = { mode: :compat, time_format: :ruby }.freeze

      def self.generate_json(obj)
        serialize_time_objects!(obj)

        Oj.dump(obj, DUMP_OPTIONS)
      end
    end

    def self.underscore(input)
      word = input.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    # Tracing information
    #
    # Tracing information is included only if OpenTracing is defined and if it
    # supports method called `active_span` (version >= 0.4.1). We use
    # SpanContext#trace_id and SpanContext#span_id methods to retrieve tracing
    # information. These methods are not yet supported by the OpenTracing API,
    # so we first check if these methods exist. Popular tracing libraries
    # already implement them. These methods are likely to be added to the API
    # very soon: https://github.com/opentracing/specification/blob/master/rfc/trace_identifiers.md
    def self.tracing_information
      if !defined?(OpenTracing) || !OpenTracing.respond_to?(:active_span)
        return NO_TRACE_INFORMATION
      end

      context = OpenTracing.active_span&.context
      if context && context.respond_to?(:trace_id) && context.respond_to?(:span_id)
        {
          trace_id: context.trace_id,
          span_id: context.span_id
        }
      else
        NO_TRACE_INFORMATION
      end
    end
    private_class_method :tracing_information
  end
end
