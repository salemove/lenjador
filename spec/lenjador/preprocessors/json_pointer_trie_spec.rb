require 'spec_helper'
require 'lenjador/preprocessors/json_pointer_trie'

RSpec.describe Lenjador::Preprocessors::JSONPointerTrie do
  let(:trie) { described_class.new }

  describe '#includes?' do
    it 'returns true for empty prefix' do
      expect(trie).to include('')
    end

    it 'returns true if trie contains requested prefix or value itself' do
      trie.insert('/data/nested/key')

      expect(trie).to include('/data')
      expect(trie).to include('/data/nested')
      expect(trie).to include('/data/nested/key')
    end

    it 'returns false if trie does not contain requested prefix or value' do
      trie.insert('/data/nested/key')

      expect(trie).not_to include('/bad_data')
      expect(trie).not_to include('/data/bad_nested')
      expect(trie).not_to include('/data/nested/bad_key')
    end

    it 'returns true if trie contains requested prefix under wildcard' do
      trie.insert('/data/~/key')

      expect(trie).to include('/data/arbitrary_key/key')
      expect(trie).to include('/data/another_key/key')
      expect(trie).not_to include('/data/arbitrary_key/bad_nested_key')
    end
  end
end
