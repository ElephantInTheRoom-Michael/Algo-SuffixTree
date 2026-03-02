# frozen_string_literal: true

require 'rspec'

RSpec.describe 'UkkonenSuffixTree' do
  context 'when the text has no repeated characters' do
    it 'checks for a full match' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abc")
      expect(tree.contains?("abc")).to be true
      expect(tree.ends_with?("abc")).to be true
      expect(tree.contains?("xyz")).to be false
      expect(tree.ends_with?("xyz")).to be false
    end

    it 'checks single character matches' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abc")
      expect(tree.contains?("a")).to be true
      expect(tree.contains?("b")).to be true
      expect(tree.contains?("c")).to be true
      expect(tree.contains?("d")).to be false
      expect(tree.ends_with?("a")).to be false
      expect(tree.ends_with?("b")).to be false
      expect(tree.ends_with?("c")).to be true
      expect(tree.ends_with?("d")).to be false
    end

    it 'checks small substrings' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abcd")
      expect(tree.contains?("ab")).to be true
      expect(tree.contains?("bc")).to be true
      expect(tree.contains?("cd")).to be true
      expect(tree.contains?("ae")).to be false
      expect(tree.contains?("be")).to be false
      expect(tree.contains?("de")).to be false
      expect(tree.contains?("ef")).to be false
      expect(tree.ends_with?("ab")).to be false
      expect(tree.ends_with?("bc")).to be false
      expect(tree.ends_with?("cd")).to be true
      expect(tree.ends_with?("ae")).to be false
      expect(tree.ends_with?("be")).to be false
      expect(tree.ends_with?("de")).to be false
      expect(tree.ends_with?("ef")).to be false
    end
  end
end
