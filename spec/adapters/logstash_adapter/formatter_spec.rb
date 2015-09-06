require 'spec_helper'
require_relative '../../../lib/logasm/adapters/logstash_adapter/formatter'

describe Logasm::Adapters::LogstashAdapter::Formatter do
  subject(:event) { formatter.call(severity, Time.now, nil, message) }

  let(:formatter)    { described_class.new(service_name) }
  let(:service_name) { 'test_service' }
  let(:severity)     { 'INFO' }
  let(:message)      { {x: 'y'} }

  it 'returns correct json' do
    hash = JSON.parse(subject)
    expect(hash['x']).to eq('y')
    expect(hash['application']).to eq('test_service')
    expect(hash['level']).to eq('info')
    expect(hash['host']).to be_a(String)
    expect(hash['@timestamp']).to match(/\d{4}-\d{2}-\d{2}T.*/)
  end
end
