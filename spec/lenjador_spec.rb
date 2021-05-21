require 'spec_helper'

describe Lenjador do
  describe '.build' do
    it 'creates stdout logger' do
      expect(described_class).to receive(:new) do |adapter|
        expect(adapter).to be_a(described_class::Adapters::StdoutAdapter)
      end

      described_class.build('test_service', {})
    end

    it 'creates stdout json logger' do
      expect(described_class).to receive(:new) do |adapter|
        expect(adapter).to be_a(described_class::Adapters::StdoutJsonAdapter)
      end

      described_class.build('test_service', json: true)
    end

    it 'creates stdout logger when no loggers are specified' do
      expect(described_class).to receive(:new) do |adapter|
        expect(adapter).to be_a(described_class::Adapters::StdoutAdapter)
      end

      described_class.build('test_service', nil)
    end

    it 'creates preprocessor when preprocessor defined' do
      expect(described_class).to receive(:new) do |_adapter, _level, preprocessors|
        expect(preprocessors.count).to be(1)
        expect(preprocessors.first).to be_a(described_class::Preprocessors::Blacklist)
      end

      preprocessors = {blacklist: {fields: []}}
      described_class.build('test_service', nil, preprocessors)
    end
  end

  context 'when preprocessor defined' do
    let(:lenjador) { described_class.new(adapter, level, [preprocessor]) }
    let(:adapter) { double }
    let(:level) { Lenjador::Severity::DEBUG }
    let(:preprocessor) { double }
    let(:data) { {data: 'data'} }

    it 'preprocesses data before logging' do
      expect(preprocessor).to receive(:process).with(data).and_return(data.merge(processed: true)).ordered
      expect(adapter).to receive(:log).with(described_class::Severity::INFO, data.merge(processed: true)).ordered

      lenjador.info(data)
    end
  end

  context 'when parsing log data' do
    let(:lenjador) { described_class.new(adapter, level, preprocessors) }
    let(:adapter) { double }
    let(:level) { Lenjador::Severity::DEBUG }
    let(:preprocessors) { [] }

    it 'parses empty string with nil metadata' do
      expect(adapter).to receive(:log).with(described_class::Severity::INFO, message: '')

      lenjador.info('', nil)
    end

    it 'parses nil as metadata' do
      expect(adapter).to receive(:log).with(described_class::Severity::INFO, message: nil)

      lenjador.info(nil)
    end

    it 'parses only message' do
      expect(adapter).to receive(:log).with(described_class::Severity::INFO, message: 'test message')

      lenjador.info 'test message'
    end

    it 'parses only metadata' do
      expect(adapter).to receive(:log).with(described_class::Severity::INFO, test: 'data')

      lenjador.info test: 'data'
    end

    it 'parses message and metadata' do
      expect(adapter).to receive(:log).with(described_class::Severity::INFO, message: 'test message', test: 'data')

      lenjador.info 'test message', test: 'data'
    end

    it 'parses block as a message' do
      message = 'test message'
      expect(adapter).to receive(:log).with(described_class::Severity::INFO, message: message)

      lenjador.info { message }
    end

    it 'ignores progname on block syntax' do
      message = 'test message'
      expect(adapter).to receive(:log).with(described_class::Severity::INFO, message: message)

      lenjador.info('progname') { message }
    end
  end

  context 'with log level' do
    context 'when adapter has debug level' do
      let(:logger) { described_class.build('test_service', level: 'debug') }

      it 'responds true to debug? and higher levels' do
        expect(logger.debug?).to be(true)
        expect(logger.info?).to be(true)
        expect(logger.warn?).to be(true)
        expect(logger.error?).to be(true)
        expect(logger.fatal?).to be(true)
      end
    end

    context 'when adapter has info level' do
      let(:logger) { described_class.build('test_service', level: 'info') }

      it 'responds true to info? and higher levels' do
        expect(logger.debug?).to be(false)
        expect(logger.info?).to be(true)
        expect(logger.warn?).to be(true)
        expect(logger.error?).to be(true)
        expect(logger.fatal?).to be(true)
      end
    end
  end

  it 'allows changing log level on existing instance' do
    logger = described_class.build('test_service', level: 'info')

    logger.level = ::Logger::DEBUG
    expect(logger.debug?).to eq(true)

    logger.level = ::Logger::INFO
    expect(logger.debug?).to eq(false)
    expect(logger.info?).to eq(true)

    logger.level = ::Logger::WARN
    expect(logger.info?).to eq(false)
    expect(logger.warn?).to eq(true)

    logger.level = ::Logger::ERROR
    expect(logger.warn?).to eq(false)
    expect(logger.error?).to eq(true)
  end
end
