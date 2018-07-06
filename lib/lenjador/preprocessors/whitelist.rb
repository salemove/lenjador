# frozen_string_literal: true

require 'lenjador/preprocessors/json_pointer_trie'
require 'lenjador/preprocessors/strategies/mask'
require 'lenjador/preprocessors/strategies/prune'

class Lenjador
  module Preprocessors
    class Whitelist
      DEFAULT_WHITELIST = %w[/id /message /correlation_id /queue].freeze
      MASK_SYMBOL = '*'
      MASKED_VALUE = MASK_SYMBOL * 5

      PRUNE_ACTION_NAMES = %w[prune exclude].freeze

      class InvalidPointerFormatException < RuntimeError
      end

      def initialize(config = {})
        trie = build_trie(config)

        @strategy = if PRUNE_ACTION_NAMES.include?(config[:action].to_s)
                      Strategies::Prune.new(trie)
                    else
                      Strategies::Mask.new(trie)
                    end
      end

      def process(data)
        @strategy.process(data)
      end

      private

      def validate_pointer(pointer)
        raise InvalidPointerFormatException, 'Pointer should not contain trailing slash' if pointer.slice(-1) == '/'
      end

      def decode(pointer)
        pointer
          .gsub('~1', '/')
          .gsub('~0', '~')
      end

      def build_trie(config)
        pointers = (config[:pointers] || []) + DEFAULT_WHITELIST

        pointers.reduce(JSONPointerTrie.new(config)) do |trie, pointer|
          validate_pointer(pointer)

          trie.insert(decode(pointer))
        end
      end
    end
  end
end
