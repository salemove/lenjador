require 'spec_helper'
require 'logasm'

module Logasm
  module Adapters
    describe StandardLoggerAdapter do
      it 'creates a stdout logger' do
        io_logger = StandardLoggerAdapter.new(0)

        logger = io_logger.instance_variable_get(:@logger)
        expect(logger).to be_a Logger

        logdev = logger.instance_variable_get(:@logdev)
        expect(logdev).to be_a Logger::LogDevice
        expect(logdev.instance_variable_get(:@dev)).to be_a IO
      end

      context 'when parsing input' do
        let!(:logger) { StandardLoggerAdapter.new(0) }

        it 'works with no input' do
          output = logger.send :format_log_data, nil

          expect(output).to eq(nil)
        end

        it 'works with only string' do
          output = logger.send :format_log_data, 'test message'

          expect(output).to eq('test message')
        end

        it 'works with only parameter' do
          output = logger.send :format_log_data, nil, test: 'param'

          expect(output).to eq('{"test":"param"}')
        end

        it 'works with multiple parameters' do
          output = logger.send :format_log_data, nil, test: 'param', more_test: 'params'

          expect(output).to eq('{"test":"param","more_test":"params"}')
        end

        it 'works with string and parameter' do
          output = logger.send :format_log_data, 'test message', test: 'param'

          expect(output).to eq('test message {"test":"param"}')
        end

        it 'works with string and multiple parameters' do
          output = logger.send :format_log_data, 'test message', test: 'param', more_test: 'params'

          expect(output).to eq('test message {"test":"param","more_test":"params"}')
        end
      end
    end
  end
end