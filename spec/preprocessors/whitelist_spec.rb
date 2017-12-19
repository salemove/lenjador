require 'spec_helper'
require_relative '../../lib/logasm/preprocessors/whitelist'

describe Logasm::Preprocessors::Whitelist do
  subject(:processed_data) { described_class.new(config).process(data) }

  let(:config) { { pointers: pointers } }
  let(:pointers) { [] }
  let(:data) do
    {
      field: 'secret',
      data: {
        field: 'secret'
      },
      array: [{ field: 'secret' }]
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
      expect { processed_data }.to raise_exception(Logasm::Preprocessors::Whitelist::InvalidPointerFormatException)
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
        array: [{ field: 'secret' }]
      )
    end
  end

  context 'with whitelisted hash' do
    it 'includes all whitelisted hash elements' do
      source = { foo: { bar: 'baz' } }
      target = { foo: { bar: 'baz' } }
      expect(process(['/foo/~'], source)).to eq(target)
    end

    it 'does not include nested elements' do
      source = { foo: { bar: { baz: 'asd' } } }
      target = { foo: { bar: { baz: '*****' } } }
      expect(process(['/foo/~'], source)).to eq(target)
    end
  end

  context 'with whitelisted array elements field with wildcard' do
    let(:data) do
      {
        array: [
          { field: 'data1', secret: 'secret1' },
          { field: 'data2', secret: 'secret2' }
        ]
      }
    end
    let(:pointers) { ['/array/~/field'] }

    it 'includes array elements field' do
      expect(processed_data).to include(
        array: [
          { field: 'data1', secret: '*****' },
          { field: 'data2', secret: '*****' }
        ]
      )
    end
  end

  context 'with whitelisted string array elements with wildcard' do
    let(:data) do
      { array: %w[secret secret] }
    end
    let(:pointers) { ['/array/~'] }

    it 'includes array elements' do
      expect(processed_data).to include(array: %w[secret secret])
    end
  end

  context 'with whitelisted string array elements in an array with wildcard' do
    let(:data) do
      {
        nested: [{ array: %w[secret secret] }]
      }
    end
    let(:pointers) { ['/nested/~/array/~'] }

    it 'includes array elements' do
      expect(processed_data).to include(nested: [{ array: %w[secret secret] }])
    end
  end


  context 'with whitelisted array element' do
    let(:pointers) { ['/array/0'] }

    it 'masks array element' do
      expect(processed_data).to include(array: [{ field: '*****' }])
    end
  end

  context 'with whitelisted array' do
    let(:pointers) { ['/array'] }

    it 'masks array' do
      expect(processed_data).to include(array: ['*****'])
    end
  end

  context 'with whitelisted hash' do
    let(:pointers) { ['/data'] }

    it 'masks hash' do
      expect(processed_data).to include(data: { field: '*****' })
    end
  end

  context 'when boolean present' do
    let(:data) { { bool: true } }

    it 'masks it with asteriks' do
      expect(processed_data).to eq(bool: '*****')
    end
  end

  context 'when field has slash in the name' do
    let(:data) do
      { 'field_with_/' => 'secret' }
    end
    let(:pointers) { ['/field_with_~1'] }

    it 'includes field' do
      expect(processed_data).to include('field_with_/'=> 'secret')
    end
  end

  context 'when field has tilde in the name' do
    let(:data) do
      { 'field_with_~' => 'secret' }
    end
    let(:pointers) { ['/field_with_~0'] }

    it 'includes field' do
      expect(processed_data).to include('field_with_~'=> 'secret')
    end
  end

  context 'when field has tilde and 1' do
    let(:data) do
      { 'field_with_~1' => 'secret' }
    end
    let(:pointers) { ['/field_with_~01'] }

    it 'includes field' do
      expect(processed_data).to include('field_with_~1'=> 'secret')
    end
  end

  def process(pointers, data)
    described_class.new(pointers: pointers).process(data)
  end
end
