require 'spec_helper'
require 'lenjador/adapters/stdout_adapter'

describe Lenjador::Adapters::StdoutAdapter do
  it 'creates a stdout logger' do
    io_logger = described_class.new('service name')

    logger = io_logger.logger
    expect(logger).to be_a Logger
  end

  describe '#log' do
    let(:adapter) { described_class.new('sevice name') }
    let(:logger) { adapter.logger }

    context 'with only a message' do
      it 'stringifies it correctly' do
        expect(logger).to receive(:add).with(Logger::Severity::INFO, 'test')

        adapter.log Lenjador::Severity::INFO, message: 'test'
      end
    end

    context 'with an empty message' do
      it 'stringifies it correctly' do
        expect(logger).to receive(:add).with(Logger::Severity::INFO, ' {"a":"b"}')

        adapter.log Lenjador::Severity::INFO, message: '', a: 'b'
      end
    end

    context 'with no message' do
      it 'stringifies it correctly' do
        expect(logger).to receive(:add).with(Logger::Severity::INFO, '{"a":"b"}')

        adapter.log Lenjador::Severity::INFO, a: 'b'
      end
    end

    context 'with a message and metadata' do
      it 'stringifies it correctly' do
        expect(logger).to receive(:add).with(Logger::Severity::INFO, 'test {"a":"b"}')

        adapter.log Lenjador::Severity::INFO, message: 'test', a: 'b'
      end
    end
  end
end
