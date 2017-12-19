require 'lru_redux'

class Logasm
  module Preprocessors
    class JSONPointerTrie
      SEPARATOR = '/'.freeze
      WILDCARD = '~'.freeze
      DEFAULT_CACHE_SIZE = 100

      def initialize(cache_size: DEFAULT_CACHE_SIZE, **)
        @root_node = {}
        @cache = LruRedux::Cache.new(cache_size)
      end

      def insert(pointer)
        split_path(pointer).reduce(@root_node) do |tree, key|
          tree[key] ||= {}
        end

        self
      end

      def include?(path)
        @cache.getset(path) { traverse_path(path) }
      end

      private

      def traverse_path(path)
        split_path(path).reduce(@root_node) do |node, key|
          node[key] || node[WILDCARD] || (break false)
        end
      end

      def split_path(path)
        path.split(SEPARATOR).reject(&:empty?)
      end
    end
  end
end
