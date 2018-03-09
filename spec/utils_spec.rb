require 'spec_helper'

describe Logasm::Utils do
  let(:now) { Time.utc(2015, 10, 11, 23, 10, 21, 123456) }

  before do
    allow(Time).to receive(:now) { now }
  end

  describe '.build_event' do
    subject(:event) { described_class.build_event(metadata, level, application_name) }

    let(:application_name) { 'test_service' }
    let(:level)  { :info }
    let(:metadata) { {x: 'y'} }

    it 'includes it in the event as application' do
      expect(event[:application]).to eq(application_name)
    end

    it 'includes log level' do
      expect(event[:level]).to eq(:info)
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
  end

  describe '.serialize_time_objects!' do
    let(:object) do
      {
        time: Time.now,
        hash: {
          time: Time.now
        },
        array: [
          Time.now,
          {
            time: Time.now
          }
        ]
      }
    end

    let(:serialized_time) { now.iso8601 }

    it 'recursively serializes time objects to iso8601' do
      o = object.dup
      described_class.serialize_time_objects!(o)

      expect(o).to eq(
        time: serialized_time,
        hash: {
          time: serialized_time
        },
        array: [
          serialized_time,
          {
            time: serialized_time
          }
        ]
      )
    end
  end
end
