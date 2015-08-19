require 'spec_helper'
require_relative '../../lib/logasm/adapters/rabbitmq_adapter'

describe Logasm::Adapters::RabbitmqAdapter do
  let(:publisher) { adapter.publisher }

  before do
    Logasm::Adapters::RabbitmqAdapter::Publisher.any_instance.stub(:initialize).and_return(double)
  end

  describe '#log' do
    context 'when logging a message' do
      let(:adapter) { described_class.new(0, nil, { host: 'localhost',
                                                    user: 'guest',
                                                    pass: 'guest',
                                                    port: '5672' }
                                          ) }

      it 'delegates to publisher' do
        expect(publisher).to receive(:publish)

        adapter.log :info, message: 'test'
      end
    end

    context 'when log level is lower than threshold' do
      let(:adapter) { described_class.new(3, nil, { host: 'localhost',
                                                    user: 'guest',
                                                    pass: 'guest',
                                                    port: '5672' }
                                          ) }

      it 'does not delegate to freddy' do
        expect(publisher).not_to receive(:publish)
        adapter.log :info, message: 'test'
      end
    end
  end
end
