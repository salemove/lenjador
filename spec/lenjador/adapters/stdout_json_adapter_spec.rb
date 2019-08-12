require 'spec_helper'
require 'json'
require 'lenjador/adapters/stdout_json_adapter'

describe Lenjador::Adapters::StdoutJsonAdapter do
  let(:stdout) { StringIO.new }

  around do |example|
    old_stdout = $stdout
    $stdout = stdout

    begin
      example.call
    ensure
      $stdout = old_stdout
    end
  end

  describe '#log' do
    let(:adapter) { described_class.new(service_name) }
    let(:metadata) { {x: 'y'} }
    let(:event) { {a: 'b', x: 'y'} }
    let(:serialized_event) { JSON.dump(event) }
    let(:service_name) { 'my-service' }
    let(:application_name) { 'my_service' }
    let(:info) { Lenjador::Severity::INFO }
    let(:info_label) { 'info' }

    before do
      allow(Lenjador::Utils).to receive(:build_event)
        .with(metadata, info_label, application_name)
        .and_return(event)
    end

    it 'sends serialized event to $stdout' do
      adapter.log(info, metadata)
      expect(output).to eq serialized_event + "\n"
    end
  end

  private

  def output
    stdout.string
  end
end
