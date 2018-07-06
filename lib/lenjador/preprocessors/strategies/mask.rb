# frozen_string_literal: true

class Lenjador
  module Preprocessors
    module Strategies
      class Mask
        MASK_SYMBOL = '*'
        MASKED_VALUE = MASK_SYMBOL * 5

        def initialize(trie)
          @trie = trie
        end

        def process(data, pointer = '')
          return MASKED_VALUE unless @trie.include?(pointer)

          case data
          when Hash
            process_hash(data, pointer)

          when Array
            process_array(data, pointer)

          else
            data
          end
        end

        private

        def process_hash(data, parent_pointer)
          data.each_with_object({}) do |(key, value), result|
            result[key] = process(value, "#{parent_pointer}/#{key}")
          end
        end

        def process_array(data, parent_pointer)
          data.each_with_index.map do |value, index|
            process(value, "#{parent_pointer}/#{index}")
          end
        end
      end
    end
  end
end
