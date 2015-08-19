require 'spec_helper'
require_relative '../../../lib/logasm/adapters/logstash_adapter/formatter'

describe Logasm::Adapters::LogstashAdapter::Formatter do
  subject(:event) { JSON.parse(formatter.call(severity, time, nil, message)) }

  let(:formatter) { described_class.new(service_name) }
  let(:service_name) { 'test_service' }
  let(:severity) { 'INFO' }
  let(:time) { Time.now }
  let(:message) { {} }

  context 'when service name is present' do
    it 'includes it in the event as application' do
      expect(event['application']).to eq('test_service')
    end
  end

  context 'when service name is not present' do
    let(:service_name) { nil }

    it 'includes does not include the application key' do
      expect(event).to_not have_key('application')
    end
  end

  it 'includes severity as lowercase level' do
    expect(event['level']).to eq('info')
  end

  it 'includes timestamp' do
    expect(event['@timestamp']).to match(/\d{4}.*/)
  end

  it 'includes the host' do
    expect(event['host']).to be_a(String)
  end
end
