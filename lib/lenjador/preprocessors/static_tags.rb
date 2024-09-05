# frozen_string_literal: true

class Lenjador
  module Preprocessors
    class StaticTags
      def initialize(tags)
        @static_tags = tags
      end

      def process(data)
        @static_tags.merge(data)
      end
    end
  end
end
