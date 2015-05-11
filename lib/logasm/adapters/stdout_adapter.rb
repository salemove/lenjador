class Logasm
  module Adapters
    class StdoutAdapter
      attr_reader :logger

      def initialize(level, *)
        @logger = Logger.new(STDOUT)
        @logger.level = level
      end

      def log(level, metadata = {})
        message = metadata[:message]
        metadata.delete(:message)
        log_data = [message, metadata.empty? ? nil : metadata.to_json].compact.join(' ')

        @logger.public_send level, log_data
      end
    end
  end
end
