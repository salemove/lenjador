require 'logasm/preprocessors/json_pointer_trie'

class Logasm
  module Preprocessors
    class Whitelist
      DEFAULT_WHITELIST = %w[/id /message /correlation_id /queue].freeze
      MASK_SYMBOL = '*'.freeze
      MASKED_VALUE = MASK_SYMBOL * 5

      class InvalidPointerFormatException < Exception
      end

      def initialize(config = {})
        pointers = (config[:pointers] || []) + DEFAULT_WHITELIST

        @trie = pointers.reduce(JSONPointerTrie.new(config)) do |trie, pointer|
          validate_pointer(pointer)

          trie.insert(decode(pointer))
        end
      end

      def process(data)
        process_data('', data)
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

      def process_data(parent_pointer, data)
        return MASKED_VALUE unless @trie.include?(parent_pointer)

        case data
        when Hash
          process_hash(parent_pointer, data)

        when Array
          process_array(parent_pointer, data)

        else
          data
        end
      end

      def process_hash(parent_pointer, hash)
        hash.each_with_object({}) do |(key, value), result|
          processed = process_data("#{parent_pointer}/#{key}", value)
          result[key] = processed
        end
      end

      def process_array(parent_pointer, array)
        array.each_with_index.map do |value, index|
          process_data("#{parent_pointer}/#{index}", value)
        end
      end
    end
  end
end
