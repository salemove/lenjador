require 'spec_helper'
require 'logasm'

module Logasm
  module Adapters
    describe LogstashAdapter do
      let!(:logstash) { LogstashAdapter.new(0, 'test_service', { host: 'localhost', port: '5228'}) }

      it 'creates a stdout logger' do
        logger = logstash.instance_variable_get(:@logger)
        expect(logger).to be_a Logger

        logdev = logger.instance_variable_get(:@logdev)

        expect(logdev).to be_a Logger::LogDevice
        expect(logdev.instance_variable_get(:@dev)).to be_a LogStashLogger::Device::UDP
      end

      it 'builds message' do
        message = logstash.send :build_message, 'test message', test: 'asdf'
        
        expect(message).to eq('{"test":"asdf","message":"test message"}')
      end 
    end
  end
end