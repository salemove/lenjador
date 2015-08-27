require 'spec_helper'
require_relative '../../lib/logasm/adapters/rabbitmq_adapter'

describe Logasm::Adapters::RabbitmqAdapter do
  let(:adapter) { described_class.new(log_level, nil, { host: 'localhost',
                                                user: 'guest',
                                                pass: 'guest',
                                                port: '5672' }
                                      ) }
  let(:freddy) { adapter.freddy }

  describe '#log' do
    context 'when logging a message' do
      let(:log_level) { 0 }

      it 'delegates to freddy' do
        expect(freddy).to receive(:deliver)

        adapter.log :info, message: 'test'
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
