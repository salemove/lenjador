require 'spec_helper'

describe Logasm do
  describe '.build' do
    it 'creates stdout logger' do
      expect(described_class).to receive(:new) do |adapters|
        expect(adapters.count).to be(1)
        expect(adapters.first).to be_a(described_class::Adapters::StdoutAdapter)
      end

      described_class.build('test_service', stdout: nil)
    end

    it 'creates stdout json logger' do
      expect(described_class).to receive(:new) do |adapters|
        expect(adapters.count).to be(1)
        expect(adapters.first).to be_a(described_class::Adapters::StdoutJsonAdapter)
      end

      described_class.build('test_service', stdout: {json: true})
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

    it 'creates preprocessor when preprocessor defined' do
      expect(described_class).to receive(:new) do |adapters, preprocessors|
        expect(preprocessors.count).to be(1)
        expect(preprocessors.first).to be_a(described_class::Preprocessors::Blacklist)
      end

      preprocessors = {blacklist: {fields: []}}
      described_class.build('test_service', nil, preprocessors)
    end
  end

  context 'when preprocessor defined' do
    let(:logasm) { described_class.new([adapter], [preprocessor]) }
    let(:adapter) { double }
    let(:preprocessor) { double }
    let(:data) { {data: 'data'} }

    it 'preprocesses data before logging' do
      expect(preprocessor).to receive(:process).with(data).and_return(data.merge(processed: true)).ordered
      expect(adapter).to receive(:log).with(:info, data.merge(processed: true)).ordered

      logasm.info(data)
    end
  end

  context 'when parsing log data' do
    let(:logasm) { described_class.new([adapter], preprocessors) }
    let(:adapter) { double }
    let(:preprocessors) { [] }

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

    it 'parses block as a message' do
      message = 'test message'
      expect(adapter).to receive(:log).with(:info, message: message)

      logasm.info { message }
    end

    it 'ignores progname on block syntax' do
      message = 'test message'
      expect(adapter).to receive(:log).with(:info, message: message)

      logasm.info('progname') { message }
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
