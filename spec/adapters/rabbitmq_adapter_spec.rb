require 'spec_helper'
require_relative '../../lib/logasm/adapters/rabbitmq_adapter'

describe Logasm::Adapters::RabbitmqAdapter do
  let(:adapter) do
    described_class.new(log_level, 'TestService', {
      host: 'localhost', user: 'guest', pass: 'guest', port: '5672'
    })
  end
  let(:bunny) { double(start: nil, create_channel: channel) }
  let(:channel) { double(default_exchange: exchange) }
  let(:exchange) { spy }

  before do
    allow(Bunny).to receive(:new) { bunny }
  end

  describe '#log' do
    context 'when logging a message' do
      let(:log_level) { 0 }

      it 'delegates to freddy' do
        adapter.log :info, message: 'test'

        expect(exchange).to have_received(:publish).with(
          match(/{"@timestamp":"\d{4}-\d{2}-\d{2}T.*","host":"\w+","message":"test","application":"test_service","level":"info"}/),
          { content_type: 'application/json', routing_key: 'logstash-queue' }
        )
      end
    end

    context 'when log level is lower than threshold' do
      let(:log_level) { 3 }

      it 'does not delegate to freddy' do
        adapter.log :info, message: 'test', a: 'b'

        expect(exchange).to_not have_received(:publish)
      end
    end
  end
end
