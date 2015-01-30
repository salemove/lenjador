module Logasm
  module Adapters
    class StandardLoggerAdapter
      def initialize(level)
        @logger = Logger.new(STDOUT)
        @logger.level = level
      end

      def log(level, message = nil, metadata = {})
        log_data = format_log_data message, metadata

        @logger.send level, log_data
      end

      private

      def format_log_data(message = nil, metadata = {})
        if message
          log_data = message
          log_data.concat(" #{metadata.to_json}") unless metadata.empty?
        else
          log_data = "#{metadata.to_json}" unless metadata.empty?
        end

        log_data
      end
    end
  end
end