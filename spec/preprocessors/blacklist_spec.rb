require 'spec_helper'
require_relative '../../lib/logasm/preprocessors/blacklist'

describe Logasm::Preprocessors::Blacklist do
  subject(:processed_data) { described_class.new(config).process(data) }

  let(:config) {{
    fields: [{ key: 'field', action: action }]
  }}

  let(:action) {}
  let(:data) {{
    field: value,
    data: {
      field: 'secret'
    },
    array: [{field: 'secret'}]
  }}

  let(:value) { 'secret' }

  context 'when action is unsupported' do
    let(:action) { 'reverse' }

    it 'throws exception' do
      expect { processed_data }.to raise_exception(Logasm::Preprocessors::Blacklist::UnsupportedActionException)
    end
  end

  context 'when action is "exclude"' do
    let(:action) { 'exclude' }

    it 'removes the field' do
      expect(processed_data).not_to include(:field)
    end

    it 'removes nested field' do
      expect(processed_data).not_to include_at_depth({field: 'secret'}, 1)
    end

    it 'removes nested in array field' do
      expect(processed_data[:array]).not_to include({field: 'secret'})
    end

    context 'when field is deeply nested' do
      let(:depth) { 10 }
      let(:data) { data_with_nested_field({field: 'secret'}, depth) }

      it 'removes deeply nested field' do
        expect(processed_data).not_to include_at_depth({field: 'secret'}, depth)
      end
    end
  end

  context 'when action is "mask"' do
    let(:action) { 'mask' }

    it 'masks nested field' do
      expect(processed_data).to include_at_depth({field: '*****'}, 1)
    end

    it 'masks nested in array field' do
      expect(processed_data[:array]).to include({field: '*****'})
    end

    context 'when field is string' do
      let(:value) { 'secret' }

      it 'masks value with asterisks' do
        expect(processed_data).to include(field: '*****')
      end
    end

    context 'when field is number' do
      let(:value) { 42 }

      it 'masks number value' do
        expect(processed_data).to include(field: '*****')
      end
    end

    context 'when field is boolean' do
      let(:value) { true }

      it 'masks value with asterisks' do
        expect(processed_data).to include(field: '*****')
      end
    end

    context 'when field is array' do
      let(:value) { [1,2,3,4] }

      it 'masks value with asterisks' do
        expect(processed_data).to include(field: '*****')
      end
    end

    context 'when field is hash' do
      let(:value) { {data: {}} }

      it 'masks value with asterisks' do
        expect(processed_data).to include(field: '*****')
      end
    end

    context 'when field is deeply nested' do
      let(:depth) { 10 }
      let(:data) { data_with_nested_field({field: 'secret'}, depth) }

      it 'masks deeply nested field' do
        expect(processed_data).to include_at_depth({field: '*****'}, depth)
      end
    end
  end

  def data_with_nested_field(field, depth)
    depth.times.inject(field) do |mem|
      {}.merge(data: mem)
    end
  end

  RSpec::Matchers.define :include_at_depth do |expected_hash, depth|
    match do |actual|
      nested_data = depth.times.inject(actual) do |mem|
        mem[:data]
      end

      expect(nested_data).to include(expected_hash)
    end
  end
end
