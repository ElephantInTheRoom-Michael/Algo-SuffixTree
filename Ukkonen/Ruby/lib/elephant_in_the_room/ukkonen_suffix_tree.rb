# frozen_string_literal: true

require_relative "ukkonen_suffix_tree/version"
require_relative "ukkonen_suffix_tree/ukkonen_suffix_tree"

module ElephantInTheRoom
  module UkkonenSuffixTree
    def self.from(text)
      ElephantInTheRoom::UkkonenSuffixTree::UkkonenSuffixTree.new.tap { _1.add(text) }
    end

    def self.empty
      ElephantInTheRoom::UkkonenSuffixTree::UkkonenSuffixTree.new
    end
  end
end
