require 'time'

class Logasm
  module Utils
    # Build logstash json compatible event
    #
    # @param [Hash] metadata
    # @param [#to_s] level
    # @param [String] service_name
    #
    # @return [Hash]
    def self.build_json_event(metadata, level, application_name)
      {
        :@timestamp => Time.now.utc,
        application: application_name,
        level: level
      }.merge(metadata)
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

    def self.underscore(input)
      word = input.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end
end
