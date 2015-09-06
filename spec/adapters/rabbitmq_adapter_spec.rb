require 'spec_helper'
require_relative '../../lib/logasm/adapters/rabbitmq_adapter'

describe Logasm::Adapters::RabbitmqAdapter do
  let(:adapter) do
    described_class.new(log_level, 'TestService', {
      host: 'localhost', user: 'guest', pass: 'guest', port: '5672'
    })
  end
  let(:freddy) { adapter.freddy }

  before do
    allow(Freddy).to receive(:build) { FreddyMock.new }
  end

  describe '#log' do
    context 'when logging a message' do
      let(:log_level) { 0 }

      it 'delegates to freddy' do
        adapter.log :info, message: 'test'

        expect(freddy.deliveries.size).to eq(1)

        queue, event = freddy.deliveries[0]
        expect(queue).to eq('logstash-queue')
        expect(event[:message]).to eq('test')
        expect(event[:application]).to eq('test_service')
        expect(event[:level]).to eq('info')
        expect(event[:host]).to be_a(String)
        expect(event[:@timestamp]).to match(/\d{4}-\d{2}-\d{2}T.*/)
      end
    end

    context 'when log level is lower than threshold' do
      let(:log_level) { 3 }

      it 'does not delegate to freddy' do
        expect(freddy).not_to receive(:deliver)

        adapter.log :info, message: 'test', a: 'b'
      end
    end
  end
end
