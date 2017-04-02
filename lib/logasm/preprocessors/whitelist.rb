class Logasm
  module Preprocessors
    class Whitelist

      DEFAULT_WHITELIST = %w(/id /message /correlation_id /queue)
      MASK_SYMBOL = '*'
      MASKED_VALUE = MASK_SYMBOL * 5
      WILDCARD = '~'

      class InvalidPointerFormatException < Exception
      end

      def initialize(config = {})
        pointers = (config[:pointers] || []) + DEFAULT_WHITELIST
        decoded_pointers = pointers
          .each(&method(:validate_pointer))
          .map(&method(:decode))
        @fields_to_include = decoded_pointers.inject({}) do |mem, pointer|
          mem.merge(pointer => true)
        end
        @wildcards = decoded_pointers
          .select(&method(:has_wildcard?))
          .inject({}) do |mem, pointer|
            mem.merge(get_wildcard_roots_of(pointer))
          end
      end

      def process(data)
        process_data('', data)
      end

      private


      def has_wildcard?(pointer)
        pointer.include?("/#{WILDCARD}/") || pointer.end_with?("/#{WILDCARD}")
      end

      # From a pointer with wildcards builds a hash with roots that contains a wildcard. Hash is used to easily match
      # find if hash element matches the pointer while processing the log.
      #
      # Example:
      #
      # Input:
      #   "/array/~/nested_array/~/fields"
      #
      # Output:
      # {
      #   "/array/~/nested_array/~" => true,
      #   "/array/~" => true
      # }
      #
      def get_wildcard_roots_of(pointer)
        if (index = pointer.rindex("/#{WILDCARD}/"))
          wildcard_root = pointer.slice(0, index + 2)
          get_wildcard_roots_of(wildcard_root).merge(wildcard_root => true)
        else
          {pointer => true}
        end
      end

      def validate_pointer(pointer)
        if pointer.slice(-1) == '/'
          raise InvalidPointerFormatException.new('Pointer should not contain trailing slash')
        end
      end

      def decode(pointer)
        pointer
          .gsub('~1', '/')
          .gsub('~0', '~')
      end

      def process_data(parent_pointer, data)
        self.send("process_#{get_type(data)}", parent_pointer, data)
      end

      def get_type(data)
        if data.is_a? Hash
          'hash'
        elsif data.is_a? Array
          'array'
        else
          'value'
        end
      end

      def process_hash(parent_pointer, hash)
        hash.inject({}) do |mem, (key, value)|
          pointer = "#{parent_pointer}/#{key}"
          processed_value = process_data(pointer, value)
          mem.merge(key => processed_value)
        end
      end

      def process_array(parent_pointer, array)
        create_child_pointer =
          if @wildcards["#{parent_pointer}/~"]
            lambda { |_| "#{parent_pointer}/~" }
          else
            lambda { |index| "#{parent_pointer}/#{index}" }
          end
        array.each_with_index.inject([]) do |mem, (value, index)|
          pointer = create_child_pointer.call(index)
          processed_value = process_data(pointer, value)
          mem + [processed_value]
        end
      end

      def process_value(parent_pointer, value)
        if @fields_to_include[parent_pointer]
          value
        else
          MASKED_VALUE
        end
      end
    end
  end
end
