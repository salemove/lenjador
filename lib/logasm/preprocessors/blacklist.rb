class Logasm
  module Preprocessors
    class Blacklist

      DEFAULT_ACTION = 'exclude'
      MASK_SYMBOL = '*'

      class UnsupportedActionException < Exception
      end

      def initialize(config = {})
        @fields_to_process = config[:fields].inject({}) do |mem, field|
          key = field.delete(:key)
          options = {action: DEFAULT_ACTION}.merge(field)
          validate_action_supported(options[:action])
          mem.merge(key => options)
        end
      end

      def process(data)
        if data.is_a? Hash
          data.inject({}) do |mem, (key, val)|
            if (field = @fields_to_process[key.to_s])
              self.send(action_method(field[:action]), mem, key, val)
            else
              mem.merge(key => process(val))
            end
          end
        elsif data.is_a? Array
          data.inject([]) do |mem, val|
            mem + [process(val)]
          end
        else
          data
        end
      end

      private

      def action_method(action)
        "#{action}_field"
      end

      def validate_action_supported(action)
        unless self.respond_to?(action_method(action).to_sym, true)
          raise UnsupportedActionException.new("Action: #{action} is not supported")
        end
      end

      def mask_field(data, key, val)
        if val.is_a?(Hash) || val.is_a?(Array) || is_boolean?(val)
          data.merge(key => MASK_SYMBOL)
        else
          data.merge(key => MASK_SYMBOL * val.to_s.length)
        end
      end

      def exclude_field(data, *)
        data
      end

      def is_boolean?(val)
        val.is_a?(TrueClass) || val.is_a?(FalseClass)
      end
    end
  end
end
