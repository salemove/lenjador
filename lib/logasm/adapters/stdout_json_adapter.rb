class Logasm
  module Adapters
    class StdoutJsonAdapter
      def initialize(level, service_name, *)
        @level = level
        @service_name = service_name
        @application_name = Utils.application_name(service_name)
      end

      def log(level, metadata = {})
        if meets_threshold?(level)
          message = Utils.build_event(metadata, level, @application_name)
          STDOUT.puts(Utils.generate_json(message))
        end
      end

      def debug?
        meets_threshold?(:debug)
      end

      def info?
        meets_threshold?(:info)
      end

      def warn?
        meets_threshold?(:warn)
      end

      def error?
        meets_threshold?(:error)
      end

      def fatal?
        meets_threshold?(:fatal)
      end

      private

      def meets_threshold?(level)
        LOG_LEVELS.index(level.to_s) >= @level
      end
    end
  end
end
