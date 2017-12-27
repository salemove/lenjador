class Logasm
  module Preprocessors
    module Strategies
      class Prune
        def initialize(trie)
          @trie = trie
        end

        def process(data, pointer = '')
          return nil unless @trie.include?(pointer)

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
            path = "#{parent_pointer}/#{key}"

            result[key] = process(value, path) if @trie.include?(path)
          end
        end

        def process_array(data, parent_pointer)
          data.each_with_index.each_with_object([]) do |(value, index), result|
            path = "#{parent_pointer}/#{index}"

            result << process(value, path) if @trie.include?(path)
          end
        end
      end
    end
  end
end
