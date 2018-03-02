class Logasm
  module Adapters
    class StdoutJsonAdapter
      OJ_DUMP_OPTS = {
        mode: :compat,
        time_format: :xmlschema,
        second_precision: 3
      }.freeze

      def initialize(level, service_name, *)
        @level = level
        @service_name = service_name
        @application_name = Utils.application_name(service_name)
      end

      def log(level, metadata = {})
        if meets_threshold?(level)
          message = Utils.build_json_event(metadata, level, @application_name)
          STDOUT.puts(Oj.dump(message, OJ_DUMP_OPTS))
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
