# frozen_string_literal: true

require 'time'
require 'oj'

class Lenjador
  module Utils
    DECIMAL_FRACTION_OF_SECOND = 3
    NO_TRACE_INFORMATION = {}.freeze
    DUMP_OPTIONS = {
      mode: :custom,
      time_format: :xmlschema,
      second_precision: 3
    }.freeze

    # Build logstash json compatible event
    #
    # @param [Hash] metadata
    # @param [#to_s] level
    # @param [String] service_name
    #
    # @return [Hash]
    def self.build_event(metadata, level, application_name)
      overwritable_params
        .merge!(metadata)
        .merge!(tracing_information)
        .merge!(
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
        :@timestamp => Time.now
      }
    end
    private_class_method :overwritable_params

    def self.generate_json(obj)
      Oj.dump(obj, DUMP_OPTIONS)
    end

    def self.underscore(input)
      word = input.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!('-', '_')
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
      return NO_TRACE_INFORMATION if !defined?(OpenTracing) || !OpenTracing.respond_to?(:active_span)

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
