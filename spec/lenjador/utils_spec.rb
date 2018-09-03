# frozen_string_literal: true

require 'spec_helper'

describe Lenjador::Utils do
  let(:now) { Time.utc(2015, 10, 11, 23, 10, 21, 123_456) }

  before do
    allow(Time).to receive(:now) { now }
  end

  describe '.build_event' do
    subject(:event) { described_class.build_event(metadata, level, application_name) }

    let(:application_name) { 'test_service' }
    let(:level) { :info }
    let(:metadata) { {x: 'y'} }

    it 'includes it in the event as application' do
      expect(event[:application]).to eq(application_name)
    end

    it 'includes log level' do
      expect(event[:level]).to eq(:info)
    end

    it 'includes timestamp' do
      expect(event[:@timestamp]).to eq(now)
    end

    context 'when @timestamp provided' do
      let(:metadata) { {message: 'test', :@timestamp => 'a timestamp'} }

      it 'overwrites @timestamp' do
        expect(event[:message]).to eq('test')
        expect(event[:@timestamp]).to eq('a timestamp')
      end
    end

    context 'when host provided' do
      let(:metadata) { {message: 'test', host: 'xyz'} }

      it 'overwrites host' do
        expect(event[:message]).to eq('test')
        expect(event[:host]).to eq('xyz')
      end
    end

    context 'when OpenTracing is defined' do
      let(:trace_id) { 'trace-id' }
      let(:span_id) { 'span-id' }

      it 'includes tracing data in the event when active span is present' do
        span_context = double(trace_id: trace_id, span_id: span_id)
        span = double(context: span_context)
        open_tracing = double(active_span: span)
        stub_const('OpenTracing', open_tracing)

        expect(event).to include(
          trace_id: trace_id,
          span_id: span_id
        )
      end

      it 'does not include tracing data if active span is not present' do
        open_tracing = double(active_span: nil)
        stub_const('OpenTracing', open_tracing)

        expect(event).not_to include(:trace_id, :span_id)
      end

      it 'does not include tracing data if active span does not respond to trace_id' do
        span_context = double(span_id: span_id)
        span = double(context: span_context)
        open_tracing = double(active_span: span)
        stub_const('OpenTracing', open_tracing)

        expect(event).not_to include(:trace_id, :span_id)
      end

      it 'does not include tracing data if active span does not respond to span_id' do
        span_context = double(trace_id: trace_id)
        span = double(context: span_context)
        open_tracing = double(active_span: span)
        stub_const('OpenTracing', open_tracing)

        expect(event).not_to include(:trace_id, :span_id)
      end
    end
  end

  describe '.generate_json' do
    it 'serializes time objects to iso8601' do
      serialized_time = now.iso8601(3)
      json = described_class.generate_json(time: now)
      expect(json).to eq(%({"time":"#{serialized_time}"}))
    end
  end
end
