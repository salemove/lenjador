class Logasm
  module Utils
    # Return application name
    #
    # Returns lower snake case application name. This allows the
    # application value to be used in the elasticsearch index name.
    #
    # @param [String, nil] service_name
    #
    # @return [String, nil]
    def self.application_name(service_name)
      if service_name
        Inflecto.underscore(service_name)
      else
        nil
      end
    end
  end
end
