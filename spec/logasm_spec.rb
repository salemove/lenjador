require 'spec_helper'

describe Logasm do
  describe '.build' do
    it 'creates file logger' do
      expect(described_class).to receive(:new) do |adapters|
        expect(adapters.count).to be(1)
        expect(adapters.first).to be_a(described_class::Adapters::StdoutAdapter)
      end

      described_class.build('test_service', stdout: nil)
    end

    it 'creates logstash logger' do
      expect(described_class).to receive(:new) do |adapters|
        expect(adapters.count).to be(1)
        expect(adapters.first).to be_a(described_class::Adapters::LogstashAdapter)
      end

      described_class.build('test_service', logstash: {host: 'localhost', port: 5228})
    end

    it 'creates multiple loggers' do
      expect(described_class).to receive(:new) do |adapters|
        expect(adapters.count).to be(2)
        expect(adapters.first).to be_a(described_class::Adapters::StdoutAdapter)
        expect(adapters.last).to be_a(described_class::Adapters::LogstashAdapter)
      end

      described_class.build('test_service', stdout: nil, logstash: {host: 'localhost', port: 5228})
    end

    it 'creates file logger when no loggers are specified' do
      expect(described_class).to receive(:new) do |adapters|
        expect(adapters.count).to be(1)
        expect(adapters.first).to be_a(described_class::Adapters::StdoutAdapter)
      end

      described_class.build('test_service', nil)
    end
  end

  context 'when parsing log data' do
    let(:logasm) { described_class.new([adapter]) }
    let(:adapter) { double }

    it 'parses empty string with nil metadata' do
      expect(adapter).to receive(:log).with(:info, message: '')

      logasm.info('', nil)
    end

    it 'parses nil as metadata' do
      expect(adapter).to receive(:log).with(:info, message: nil)

      logasm.info(nil)
    end

    it 'parses only message' do
      expect(adapter).to receive(:log).with(:info, message: 'test message')

      logasm.info 'test message'
    end

    it 'parses only metadata' do
      expect(adapter).to receive(:log).with(:info, test: 'data')

      logasm.info test: 'data'
    end

    it 'parses message and metadata' do
      expect(adapter).to receive(:log).with(:info, message: 'test message', test: 'data')

      logasm.info 'test message', test: 'data'
    end
  end

  context 'log level queries' do
    context 'when one adapter has debug level' do
      let(:logger) do
        described_class.build(
          'test_service',
          stdout: {level: 'debug'},
          logstash: {level: 'info', host: '127.0.0.1', port: 5228 },
          rabbitmq: {level: 'fatal'},
        )
      end

      it 'responds true to debug? and higher levels' do
        expect(logger.debug?).to be(true)
        expect(logger.info?).to be(true)
        expect(logger.warn?).to be(true)
        expect(logger.error?).to be(true)
        expect(logger.fatal?).to be(true)
      end
    end

    context 'when one adapter has info level' do
      let(:logger) do
        described_class.build(
          'test_service',
          rabbitmq: {level: 'info'},
          stdout: {level: 'warn'},
          logstash: {level: 'warn', host: '127.0.0.1', port: 5228 },
        )
      end

      it 'responds true to info? and higher levels' do
        expect(logger.debug?).to be(false)
        expect(logger.info?).to be(true)
        expect(logger.warn?).to be(true)
        expect(logger.error?).to be(true)
        expect(logger.fatal?).to be(true)
      end
    end
  end

  it 'has the same interface as Ruby logger' do
    skip "https://salemove.atlassian.net/browse/INF-464"
    logger = described_class.build('test_service', stdout: {level: 'debug'})
    expect(logger).to implement_interface(Logger)
  end
end
