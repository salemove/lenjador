require 'spec_helper'

describe Logasm::Utils do
  describe '.build_event' do
    subject(:event) { described_class.build_event(metadata, level, application_name) }

    let(:application_name) { 'test_service' }
    let(:level)  { :info }
    let(:metadata) { {x: 'y'} }

    before do
      allow(Time).to receive(:now) { Time.utc(2015, 10, 11, 23, 10, 21, 123456) }
    end

    it 'includes it in the event as application' do
      expect(event[:application]).to eq(application_name)
    end

    it 'includes log level' do
      expect(event[:level]).to eq('info')
    end

    it 'includes timestamp' do
      expect(event[:@timestamp]).to eq('2015-10-11T23:10:21.123Z')
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

    context 'when time object in metadata' do
      let(:metadata) { {time: Time.utc(2016, 1, 5, 10, 38)} }

      it 'serializes as iso8601 format' do
        expect(subject[:time]).to eq("2016-01-05T10:38:00Z")
      end
    end
  end
end
