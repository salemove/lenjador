require 'spec_helper'
require_relative '../../lib/logasm/adapters/rabbitmq_adapter'

describe Logasm::Adapters::RabbitmqAdapter do
  let(:adapter) { described_class.new(0, nil, { host: 'localhost',
                                                user: 'guest',
                                                pass: 'guest',
                                                port: '5672' }
                                      ) }
  let(:freddy) { adapter.freddy }

  before do
    Logasm::Adapters::RabbitmqAdapter::MessageBuilder.any_instance.stub(:build_message).and_return(nil)
  end

  describe '#log' do
    context 'with only a message' do
      it 'delegates to freddy' do
        expect(freddy).to receive(:deliver).with('logstash-queue', message: 'test')

        adapter.log :info, message: 'test'
      end
    end

    context 'with an empty message' do
      it 'delegates to freddy' do
        expect(freddy).to receive(:deliver).with('logstash-queue', message: '', a: 'b')

        adapter.log :info, message: '', a: 'b'
      end
    end

    context 'with no message' do
      it 'delegates to freddy' do
        expect(freddy).to receive(:deliver).with('logstash-queue', a: 'b')

        adapter.log :info, a: 'b'
      end
    end

    context 'with a message and metadata' do
      it 'delegates to freddy' do
        expect(freddy).to receive(:deliver).with('logstash-queue', message: 'test', a: 'b')

        adapter.log :info, message: 'test', a: 'b'
      end
    end

    context 'with a message and metadata' do
      it 'delegates to freddy' do
        expect(freddy).to receive(:deliver).with('logstash-queue', message: 'test', a: 'b')

        adapter.log :info, message: 'test', a: 'b'
      end
    end

    context 'when log level is lower than threshold' do
      let(:adapter) { described_class.new(3, nil, { host: 'localhost',
                                                    user: 'guest',
                                                    pass: 'guest',
                                                    port: '5672' }
                                          ) }

      it 'does not delegate to freddy' do
        expect(freddy).not_to receive(:deliver)

        adapter.log :info, message: 'test', a: 'b'
      end
    end
  end
end
