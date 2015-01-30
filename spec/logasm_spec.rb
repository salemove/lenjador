require 'spec_helper'
require 'logasm'

module Logasm
  describe Logasm do
    it 'creates file logger' do
      logasm = Logasm.new({file: nil}, 'test_service')
      number_of_loggers = logasm.loggers.count

      expect(number_of_loggers).to eq(1)

      logger = logasm.loggers[0].instance_variable_get(:@logger)
      expect(logger).to be_a Logger

      logdev = logger.instance_variable_get(:@logdev)

      expect(logdev).to be_a Logger::LogDevice
      expect(logdev.instance_variable_get(:@dev)).to be_a IO
    end

    it 'creates logstash logger' do
      logasm = Logasm.new({logstash: {host: 'localhost', port: 5228}}, 'test_service')
      number_of_loggers = logasm.loggers.count

      expect(number_of_loggers).to eq(1)

      logger = logasm.loggers[0].instance_variable_get(:@logger)
      expect(logger).to be_a Logger

      logdev = logger.instance_variable_get(:@logdev)

      expect(logdev).to be_a Logger::LogDevice
      expect(logdev.instance_variable_get(:@dev)).to be_a LogStashLogger::Device::UDP
    end

    it 'creates multiple loggers' do
      logasm = Logasm.new({file: nil, logstash: {host: 'localhost', port: 5228}}, 'test_service')
      number_of_loggers = logasm.loggers.count

      expect(number_of_loggers).to eq(2)

      logger_io = logasm.loggers[0].instance_variable_get(:@logger)
      expect(logger_io).to be_a Logger

      logdev_io = logger_io.instance_variable_get(:@logdev)

      expect(logdev_io).to be_a Logger::LogDevice
      expect(logdev_io.instance_variable_get(:@dev)).to be_a IO

      logger_logstash = logasm.loggers[1].instance_variable_get(:@logger)
      expect(logger_logstash).to be_a Logger

      logdev_logstash = logger_logstash.instance_variable_get(:@logdev)

      expect(logdev_logstash).to be_a Logger::LogDevice
      expect(logdev_logstash.instance_variable_get(:@dev)).to be_a LogStashLogger::Device::UDP
    end

    it 'creates file logger when no loggers are specified' do
      logasm = Logasm.new(nil,'test_service')
      number_of_loggers = logasm.loggers.count

      expect(number_of_loggers).to eq(1)

      logger = logasm.loggers[0].instance_variable_get(:@logger)
      expect(logger).to be_a Logger

      logdev = logger.instance_variable_get(:@logdev)

      expect(logdev).to be_a Logger::LogDevice
      expect(logdev.instance_variable_get(:@dev)).to be_a IO
    end

    context 'when parsing log data' do
      let!(:logasm) { Logasm.new(nil,'test_service') }

      it 'parses no message and no metadata' do
        message, metadata = logasm.send :parse_log_data

        expect(message).to eq(nil)
        expect(metadata).to eq({})
      end

      it 'parses only message' do
        message, metadata = logasm.send :parse_log_data, 'test message'

        expect(message).to eq('test message')
        expect(metadata).to eq({})
      end

      it 'parses only metadata' do
        message, metadata = logasm.send :parse_log_data, test: 'data'

        expect(message).to eq(nil)
        expect(metadata).to eq({test: 'data'})
      end

      it 'parses message and metadata' do
        message, metadata = logasm.send :parse_log_data, 'test message', test: 'data'

        expect(message).to eq('test message')
        expect(metadata).to eq({test: 'data'})
      end
    end
  end
end
