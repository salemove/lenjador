require 'spec_helper'
require_relative '../../../lib/logasm/adapters/rabbitmq_adapter/message_builder'

describe Logasm::Adapters::RabbitmqAdapter::MessageBuilder do
  subject { message_builder.build_message(metadata, level) }

  let(:message_builder) { described_class.new(service_name) }
  let(:service_name) { 'test_service' }
  let(:level) { :info }
  let(:metadata) { {message: 'test'} }

  it 'adds necessary arguments' do
    expect(subject[:message]).to eq(metadata[:message])
    expect(subject[:application]).to eq(service_name)
    expect(subject[:level]).to eq(level)
    expect(subject).to have_key(:host)
    expect(subject).to have_key(:@timestamp)
  end

  context 'when service name is camelcase' do
    let(:service_name) { 'InformationService' }

    it 'converts it to lower snake case' do
      expect(subject[:application]).to eq('information_service')
    end
  end
end
