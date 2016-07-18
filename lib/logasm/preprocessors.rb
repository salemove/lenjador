class Logasm
  module Preprocessors
    def self.get(type, arguments)
      require_relative "preprocessors/#{type.to_s}"
      preprocessor = const_get(Inflecto.camelize(type.to_s))
      preprocessor.new(arguments)
    end
  end
end
