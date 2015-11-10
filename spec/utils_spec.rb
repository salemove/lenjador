require 'spec_helper'

describe Logasm::Utils do
  describe '.build_event' do
    subject(:event) { described_class.build_event(metadata, level, service_name) }

    let(:service_name) { 'test_service' }
    let(:level)        { 'INFO' }
    let(:metadata)     { {x: 'y'} }

    before do
      allow(Time).to receive(:now) { Time.utc(2015, 10, 11, 23, 10, 21, 123456) }
    end

    context 'when service name is in correct format' do
      it 'includes it in the event as application' do
        expect(event[:application]).to eq('test_service')
      end
    end

    context 'when service name is in camelcase' do
      let(:service_name) { 'InformationService' }

      it 'includes it in the event as lower snake case' do
        expect(event[:application]).to eq('information_service')
      end
    end

    it 'includes level as a lower case string' do
      expect(event[:level]).to eq('info')
    end

    it 'includes timestamp' do
      expect(event[:@timestamp]).to eq('2015-10-11T23:10:21.123Z')
    end

    it 'includes the host' do
      expect(event[:host]).to be_a(String)
    end

    context 'when @timestamp provided' do
      let(:metadata) { {message: 'test', :@timestamp => 'a timestamp'} }

      it 'overwrites @timestamp' do
        expect(subject[:message]).to eq('test')
        expect(subject[:@timestamp]).to eq('a timestamp')
      end
    end

    context 'when host provided' do
      let(:metadata) { {message: 'test', host: 'xyz'} }

      it 'overwrites host' do
        expect(subject[:message]).to eq('test')
        expect(subject[:host]).to eq('xyz')
      end
    end
  end
end
