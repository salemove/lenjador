# frozen_string_literal: true

class Lenjador
  module Adapters
    class StdoutJsonAdapter
      def initialize(service_name)
        @application_name = Utils.application_name(service_name)
        @mutex = Mutex.new if RUBY_ENGINE == 'jruby'
      end

      def log(level, metadata = {})
        message = Utils.build_event(metadata, Lenjador::SEV_LABEL[level], @application_name)
        print_line(Utils.generate_json(message))
      end

      private

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
