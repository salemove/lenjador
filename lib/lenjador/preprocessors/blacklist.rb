# frozen_string_literal: true

class Lenjador
  module Preprocessors
    class Blacklist
      DEFAULT_ACTION = 'prune'
      MASK_SYMBOL = '*'
      MASKED_VALUE = MASK_SYMBOL * 5

      class UnsupportedActionException < RuntimeError
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
              send(action_method(field[:action]), mem, key, val)
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
        unless respond_to?(action_method(action).to_sym, true)
          raise UnsupportedActionException, "Action: #{action} is not supported"
        end
      end

      def mask_field(data, key, _val)
        data.merge(key => MASKED_VALUE)
      end

      def prune_field(data, *)
        data
      end
      alias exclude_field prune_field
    end
  end
end
