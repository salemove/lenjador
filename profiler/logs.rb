# frozen_string_literal: true

# Run with `ruby profiler/logs.rb > /dev/null` and then you can read the
# results using `open /tmp/lenjador.html`

require 'bundler/setup'
Bundler.require
logger = Lenjador.build('test_service', stdout: {level: 'info', json: true})

require 'ruby-prof'
RubyProf.start

100_000.times do
  logger.info 'hello there', a: 'asdf', b: 'eadsfasdf', c: {hello: 'there'}
end

result = RubyProf.stop
printer = RubyProf::GraphHtmlPrinter.new(result)
File.open('/tmp/lenjador.html', 'w+') { |file| printer.print(file) }
