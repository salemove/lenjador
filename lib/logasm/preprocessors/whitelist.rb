require 'logasm/preprocessors/json_pointer_trie'
require 'logasm/preprocessors/strategies/mask'
require 'logasm/preprocessors/strategies/prune'

class Logasm
  module Preprocessors
    class Whitelist
      DEFAULT_WHITELIST = %w[/id /message /correlation_id /queue].freeze
      MASK_SYMBOL = '*'.freeze
      MASKED_VALUE = MASK_SYMBOL * 5

      PRUNE_ACTION_NAMES = %w[prune exclude].freeze

      # A special constant to indicate that a value should be pruned from the output

      class InvalidPointerFormatException < Exception
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
        if pointer.slice(-1) == '/'
          raise InvalidPointerFormatException, 'Pointer should not contain trailing slash'
        end
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
