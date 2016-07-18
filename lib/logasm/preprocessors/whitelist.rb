class Logasm
  module Preprocessors
    class Whitelist

      DEFAULT_WHITELIST = %w(/id /message /correlation_id /queue)
      MASK_SYMBOL = '*'

      class InvalidPointerFormatException < Exception
      end

      def initialize(config = {})
        pointers = (config[:pointers] || []) + DEFAULT_WHITELIST
        @fields_to_include = pointers.inject({}) do |mem, pointer|
          validate_pointer(pointer)
          mem.merge(decode(pointer) => true)
        end
      end

      def process(data)
        process_data('', data)
      end

      private

      def validate_pointer(pointer)
        if pointer.slice(-1) == '/'
          raise InvalidPointerFormatException.new('Pointer should not contain trailing slash')
        end
      end

      def decode(pointer)
        pointer
          .gsub('~0', '~')
          .gsub('~1', '/')
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
        array.each_with_index.inject([]) do |mem, (value, index)|
          pointer = "#{parent_pointer}/#{index}"
          processed_value = process_data(pointer, value)
          mem + [processed_value]
        end
      end

      def process_value(parent_pointer, value)
        if @fields_to_include[parent_pointer]
          value
        else
          mask value
        end
      end

      def mask(value)
        if value && value.respond_to?(:to_s) && !is_boolean?(value)
          MASK_SYMBOL * value.to_s.length
        else
          MASK_SYMBOL
        end
      end

      def is_boolean?(value)
        value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end
    end
  end
end
