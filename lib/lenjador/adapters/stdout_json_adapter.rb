# frozen_string_literal: true

class Lenjador
  module Adapters
    class StdoutJsonAdapter
      def initialize(level, service_name, *)
        @level = level
        @service_name = service_name
        @application_name = Utils.application_name(service_name)
        @mutex = Mutex.new if RUBY_ENGINE == 'jruby'
      end

      def log(level, metadata = {})
        return unless meets_threshold?(level)

        message = Utils.build_event(metadata, level, @application_name)
        print_line(Utils.generate_json(message))
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

      # puts is atomic in MRI starting from 2.5.0
      if RUBY_ENGINE == 'ruby' && RUBY_VERSION >= '2.5.0'
        def print_line(str)
          $stdout.puts(str)
        end
      elsif RUBY_ENGINE == 'jruby'
        def print_line(str)
          @mutex.synchronize { $stdout.write(str + "\n") }
        end
      else
        def print_line(str)
          $stdout.write(str + "\n")
        end
      end
    end
  end
end
