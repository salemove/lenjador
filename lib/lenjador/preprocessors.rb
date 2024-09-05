# frozen_string_literal: true

class Lenjador
  module Preprocessors
    def self.get(type, arguments)
      preprocessor =
        case type.to_s
        when 'blacklist'
          require_relative 'preprocessors/blacklist'
          Preprocessors::Blacklist
        when 'whitelist'
          require_relative 'preprocessors/whitelist'
          Preprocessors::Whitelist
        when 'static_tags'
          require_relative 'preprocessors/static_tags'
          Preprocessors::StaticTags
        else
          raise "Unknown preprocessor: #{type}"
        end
      preprocessor.new(arguments)
    end
  end
end
