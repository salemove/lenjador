require 'spec_helper'
require 'logasm'

describe Logasm::Adapters::StdoutAdapter do
  it 'creates a stdout logger' do
    io_logger = described_class.new(0)

    logger = io_logger.instance_variable_get(:@logger)
    expect(logger).to be_a Logger
  end

  describe '#log' do
    let(:adapter) { described_class.new(0) }
    let(:logger) { adapter.logger }

    context 'with only a message' do
      it 'stringifies it correctly' do
        expect(logger).to receive(:info).with('test')

        adapter.log :info, message: 'test'
      end
    end

    context 'with an empty message' do
      it 'stringifies it correctly' do
        expect(logger).to receive(:info).with(' {"a":"b"}')

        adapter.log :info, message: '', a: 'b'
      end
    end

    context 'with no message' do
      it 'stringifies it correctly' do
        expect(logger).to receive(:info).with('{"a":"b"}')

        adapter.log :info, a: 'b'
      end
    end

    context 'with a message and metadata' do
      it 'stringifies it correctly' do
        expect(logger).to receive(:info).with('test {"a":"b"}')

        adapter.log :info, message: 'test', a: 'b'
      end
    end
  end
end
