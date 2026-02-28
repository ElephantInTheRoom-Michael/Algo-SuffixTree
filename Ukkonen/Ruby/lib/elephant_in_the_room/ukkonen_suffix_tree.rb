# frozen_string_literal: true

require_relative "ukkonen_suffix_tree/version"

module ElephantInTheRoom
  module UkkonenSuffixTree
    require_relative "ukkonen_suffix_tree/ukkonen_suffix_tree"

    def self.from(text)
      UkkonenSuffixTree.new.tap { _1.add(text) }
    end
  end
end
