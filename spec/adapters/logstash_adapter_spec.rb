require 'spec_helper'

describe Logasm::Adapters::LogstashAdapter do
  let(:logstash) { described_class.new(0, 'test_service', { host: 'localhost', port: '5228'}) }
  let(:logger) { logstash.logger }

  it 'delegates to the logger' do
    expect(logger).to receive(:info).with(message: 'test')

    logstash.log :info, message: 'test'
  end
end
