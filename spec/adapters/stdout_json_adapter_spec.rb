require 'spec_helper'
require 'json'
require_relative '../../lib/logasm/adapters/stdout_json_adapter'

describe Logasm::Adapters::StdoutJsonAdapter do
  let(:debug_level_code) { 0 }
  let(:debug_level) { Logasm::Adapters::LOG_LEVELS[debug_level_code] }
  let(:info_level_code) { 1 }
  let(:info_level) { Logasm::Adapters::LOG_LEVELS[info_level_code] }

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
    context 'when below threshold' do
      let(:adapter) { described_class.new(debug_level_code, service_name) }
      let(:metadata) { {x: 'y'} }
      let(:event) { {a: 'b', x: 'y'} }
      let(:serialized_event) { JSON.dump(event) }
      let(:service_name) { 'my-service' }
      let(:application_name) { 'my_service' }

      before do
        allow(Logasm::Utils).to receive(:build_event)
          .with(metadata, info_level, application_name)
          .and_return(event)
      end

      it 'sends serialized event to $stdout' do
        adapter.log(info_level, metadata)
        expect(output).to eq serialized_event + "\n"
      end
    end

    context 'when above threshold' do
      let(:adapter) { described_class.new(info_level_code, service_name) }
      let(:metadata) { {x: 'y'} }
      let(:service_name) { 'my-service' }

      it 'does not log the event' do
        adapter.log(debug_level, metadata)
        expect(output).to be_empty
      end
    end
  end

  private

  def output
    stdout.string
  end
end
