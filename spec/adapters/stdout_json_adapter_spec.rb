require 'spec_helper'
require_relative '../../lib/logasm/adapters/stdout_json_adapter'

describe Logasm::Adapters::StdoutJsonAdapter do
  let(:debug_level_code) { 0 }
  let(:debug_level) { Logasm::Adapters::LOG_LEVELS[debug_level_code] }
  let(:info_level_code) { 1 }
  let(:info_level) { Logasm::Adapters::LOG_LEVELS[info_level_code] }

  describe '#log' do
    context 'when below threshold' do
      let(:adapter) { described_class.new(debug_level_code, service_name) }
      let(:metadata) { {x: 'y'} }
      let(:event) { {a: 'b', x: 'y'} }
      let(:serialized_event) { JSON.dump(event) }
      let(:service_name) { 'my-service' }

      before do
        allow(Logasm::Utils).to receive(:build_event)
          .with(metadata, info_level, service_name)
          .and_return(event)
      end

      it 'sends serialized event to STDOUT' do
        expect(STDOUT).to receive(:puts).with(serialized_event)
        adapter.log(info_level, metadata)
      end
    end

    context 'when above threshold' do
      let(:adapter) { described_class.new(info_level_code, service_name) }
      let(:metadata) { {x: 'y'} }
      let(:service_name) { 'my-service' }

      it 'does not log the event' do
        expect(STDOUT).to_not receive(:puts)
        adapter.log(debug_level, metadata)
      end
    end
  end
end
