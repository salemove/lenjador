require 'spec_helper'
require_relative '../../../lib/lenjador/preprocessors/whitelist'

RSpec.describe Lenjador::Preprocessors::Whitelist do
  context 'when :action is :mask or omitted' do
    subject(:processed_data) { described_class.new(config).process(data) }

    let(:config) { {pointers: pointers} }
    let(:pointers) { [] }
    let(:data) do
      {
        field: 'secret',
        data: {
          field: 'secret'
        },
        array: [{field: 'secret'}]
      }
    end

    it 'masks all non-whitelisted fields' do
      expect(processed_data).to eq(
        field: '*****',
        data: '*****',
        array: '*****'
      )
    end

    context 'when pointer has trailing slash' do
      let(:pointers) { ['/field/'] }

      it 'throws exception' do
        expect { processed_data }.to raise_exception(Lenjador::Preprocessors::Whitelist::InvalidPointerFormatException)
      end
    end

    context 'with whitelisted field' do
      let(:pointers) { ['/field'] }

      it 'includes the field' do
        expect(processed_data).to eq(
          field: 'secret',
          data: '*****',
          array: '*****'
        )
      end
    end

    context 'with whitelisted nested field' do
      let(:pointers) { ['/data/field'] }

      it 'includes nested field' do
        expect(processed_data).to eq(
          field: '*****',
          data: {
            field: 'secret'
          },
          array: '*****'
        )
      end
    end

    context 'with whitelisted array element field' do
      let(:pointers) { ['/array/0/field'] }

      it 'includes array element' do
        expect(processed_data).to eq(
          field: '*****',
          data: '*****',
          array: [{field: 'secret'}]
        )
      end
    end

    context 'with whitelisted hash' do
      it 'includes all whitelisted hash elements' do
        source = {foo: {bar: 'baz'}}
        target = {foo: {bar: 'baz'}}
        expect(process(['/foo/~'], source)).to eq(target)
      end

      it 'does not include nested elements' do
        source = {foo: {bar: {baz: 'asd'}}}
        target = {foo: {bar: {baz: '*****'}}}
        expect(process(['/foo/~'], source)).to eq(target)
      end
    end

    context 'with whitelisted array elements field with wildcard' do
      let(:data) do
        {
          array: [
            {field: 'data1', secret: 'secret1'},
            {field: 'data2', secret: 'secret2'}
          ]
        }
      end
      let(:pointers) { ['/array/~/field'] }

      it 'includes array elements field' do
        expect(processed_data).to include(
          array: [
            {field: 'data1', secret: '*****'},
            {field: 'data2', secret: '*****'}
          ]
        )
      end
    end

    context 'with whitelisted string array elements with wildcard' do
      let(:data) do
        {array: %w[secret secret]}
      end
      let(:pointers) { ['/array/~'] }

      it 'includes array elements' do
        expect(processed_data).to include(array: %w[secret secret])
      end
    end

    context 'with whitelisted string array elements in an array with wildcard' do
      let(:data) do
        {
          nested: [{array: %w[secret secret]}]
        }
      end
      let(:pointers) { ['/nested/~/array/~'] }

      it 'includes array elements' do
        expect(processed_data).to include(nested: [{array: %w[secret secret]}])
      end
    end

    context 'with whitelisted array element' do
      let(:pointers) { ['/array/0'] }

      it 'masks array element' do
        expect(processed_data).to include(array: [{field: '*****'}])
      end
    end

    context 'with whitelisted array' do
      let(:pointers) { ['/array'] }

      it 'masks array' do
        expect(processed_data).to include(array: ['*****'])
      end
    end

    context 'when boolean present' do
      let(:pointers) { ['/bool'] }
      let(:data) do
        {
          bool: true,
          bool2: true
        }
      end

      it 'masks only if not in whitelist' do
        expect(processed_data).to eq({
          bool: true,
          bool2: '*****'
        })
      end
    end

    context 'when nil present' do
      let(:pointers) { ['/nil'] }
      let(:data) do
        {
          nil: nil,
          nil2: nil
        }
      end

      it 'masks only if not in whitelist' do
        expect(processed_data).to eq({
          nil: nil,
          nil2: '*****'
        })
      end
    end

    context 'when numbers present' do
      let(:data) do
        {
          integer: 1,
          float: 2.03,
          integer2: 3,
          float2: 3.34324
        }
      end
      let(:pointers) { ['/integer', '/float'] }

      it 'masks only if not in whitelist' do
        expect(processed_data).to eq({
          integer: 1,
          float: 2.03,
          integer2: '*****',
          float2: '*****'
        })
      end
    end

    context 'when symbol present' do
      let(:data) do
        {
          symbol1: :symbol1,
          symbol2: :symbol2
        }
      end
      let(:pointers) { ['/symbol1'] }

      it 'masks only if not in whitelist' do
        expect(processed_data).to eq({
          symbol1: :symbol1,
          symbol2: '*****'
        })
      end
    end

    context 'when date time present' do
      let(:data) do
        {
          date: Date.new(2023, 12, 12),
          time: Time.new(2023, 12, 13),
          datetime: DateTime.new(2023, 12, 14)
        }
      end
      let(:pointers) { ['/date', '/time', '/datetime'] }

      it 'shows dates' do
        expect(processed_data).to eq({
          date: Date.new(2023, 12, 12),
          time: Time.new(2023, 12, 13),
          datetime: DateTime.new(2023, 12, 14)
        })
      end
    end

    context 'when unsupported object present' do
      let(:pointers) { ['/field'] }
      let(:some_class) { OpenStruct.new(name: 'Rowdy', pin_code: '1234') }
      let(:data) { {field: some_class} }

      it 'masks the object' do
        expect(processed_data).to eq(
          field: '*****'
        )
      end
    end

    context 'when field has slash in the name' do
      let(:data) do
        {'field_with_/' => 'secret'}
      end
      let(:pointers) { ['/field_with_~1'] }

      it 'includes field' do
        expect(processed_data).to include('field_with_/' => 'secret')
      end
    end

    context 'when field has tilde in the name' do
      let(:data) do
        {'field_with_~' => 'secret'}
      end
      let(:pointers) { ['/field_with_~0'] }

      it 'includes field' do
        expect(processed_data).to include('field_with_~' => 'secret')
      end
    end

    context 'when field has tilde and 1' do
      let(:data) do
        {'field_with_~1' => 'secret'}
      end
      let(:pointers) { ['/field_with_~01'] }

      it 'includes field' do
        expect(processed_data).to include('field_with_~1' => 'secret')
      end
    end

    def process(pointers, data)
      described_class.new(pointers: pointers).process(data)
    end
  end

  context 'when :action is :exclude or :prune' do
    subject(:processed_data) { described_class.new(config).process(data) }

    let(:config) { {pointers: pointers, action: :prune} }
    let(:pointers) { [] }
    let(:data) do
      {
        field: 'secret',
        data: {
          field: 'secret'
        },
        array: [{field: 'secret'}, {field2: 'secret'}]
      }
    end

    context 'when pointers is empty' do
      it 'prunes all fields from the input' do
        expect(processed_data).to eq({})
      end
    end

    context 'with whitelisted field' do
      let(:pointers) { ['/field'] }

      it 'includes the field' do
        expect(processed_data).to eq(field: 'secret')
      end
    end

    context 'with whitelisted nested field' do
      let(:pointers) { ['/data/field'] }

      it 'includes nested field' do
        expect(processed_data).to eq(data: {field: 'secret'})
      end
    end

    context 'with whitelisted array element field' do
      let(:pointers) { ['/array/0/field'] }

      it 'includes array element' do
        expect(processed_data).to eq(array: [{field: 'secret'}])
      end
    end

    context 'with whitelisted hash' do
      it 'includes all whitelisted hash elements' do
        source = {foo: {bar: 'baz'}}
        target = {foo: {bar: 'baz'}}
        expect(process(['/foo/~'], source)).to eq(target)
      end

      it 'does not include nested elements' do
        source = {foo: {bar: {baz: 'asd'}}}
        target = {foo: {bar: {}}}
        expect(process(['/foo/~'], source)).to eq(target)
      end
    end

    context 'with whitelisted array elements field with wildcard' do
      let(:data) do
        {
          array: [
            {field: 'data1', secret: 'secret1'},
            {field: 'data2', secret: 'secret2'}
          ]
        }
      end
      let(:pointers) { ['/array/~/field'] }

      it 'includes array elements field' do
        expect(processed_data).to include(
          array: [
            {field: 'data1'},
            {field: 'data2'}
          ]
        )
      end
    end

    context 'with whitelisted string array elements with wildcard' do
      let(:data) do
        {array: %w[secret1 secret2]}
      end
      let(:pointers) { ['/array/~'] }

      it 'includes array elements' do
        expect(processed_data).to include(array: %w[secret1 secret2])
      end
    end

    context 'with whitelisted string array elements in an array with wildcard' do
      let(:data) do
        {
          nested: [{array: %w[secret1 secret2]}]
        }
      end
      let(:pointers) { ['/nested/~/array/~'] }

      it 'includes array elements' do
        expect(processed_data).to include(nested: [{array: %w[secret1 secret2]}])
      end
    end

    context 'with whitelisted array element' do
      let(:pointers) { ['/array/0'] }

      it 'masks array element' do
        expect(processed_data).to eq(array: [{}])
      end
    end

    context 'with whitelisted array' do
      let(:pointers) { ['/array'] }

      it 'masks array' do
        expect(processed_data).to include(array: [])
      end
    end

    context 'when boolean present' do
      let(:pointers) { ['/bool'] }
      let(:data) do
        {
          bool: true,
          bool2: true
        }
      end

      it 'prunes only if not in whitelist' do
        expect(processed_data).to eq({
          bool: true
        })
      end
    end

    context 'when nil present' do
      let(:pointers) { ['/nil'] }
      let(:data) do
        {
          nil: nil,
          nil2: nil
        }
      end

      it 'prunes only if not in whitelist' do
        expect(processed_data).to eq({
          nil: nil
        })
      end
    end

    context 'when numbers present' do
      let(:data) do
        {
          integer: 1,
          float: 2.03,
          integer2: 3,
          float2: 3.34324
        }
      end
      let(:pointers) { ['/integer', '/float'] }

      it 'prunes only if not in whitelist' do
        expect(processed_data).to eq({
          integer: 1,
          float: 2.03
        })
      end
    end

    context 'when symbol present' do
      let(:data) do
        {
          symbol1: :symbol1,
          symbol2: :symbol2
        }
      end
      let(:pointers) { ['/symbol1'] }

      it 'prunes only if not in whitelist' do
        expect(processed_data).to eq({
          symbol1: :symbol1
        })
      end
    end

    context 'when date time present' do
      let(:data) do
        {
          date: Date.new(2023, 12, 12),
          time: Time.new(2023, 12, 13),
          datetime: DateTime.new(2023, 12, 14)
        }
      end
      let(:pointers) { ['/date', '/time', '/datetime'] }

      it 'shows dates' do
        expect(processed_data).to eq({
          date: Date.new(2023, 12, 12),
          time: Time.new(2023, 12, 13),
          datetime: DateTime.new(2023, 12, 14)
        })
      end
    end

    context 'when unsupported object present' do
      let(:pointers) { ['/class'] }
      let(:some_class) { OpenStruct.new(name: 'Rowdy', pin_code: '1234') }

      let(:data) { {class: some_class} }

      it 'does not return the object' do
        expect(processed_data).to eq({class: nil})
      end
    end

    def process(pointers, data)
      described_class.new(pointers: pointers, action: :prune).process(data)
    end
  end
end
