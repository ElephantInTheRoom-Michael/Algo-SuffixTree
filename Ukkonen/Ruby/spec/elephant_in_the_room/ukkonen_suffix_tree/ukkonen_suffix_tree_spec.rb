# frozen_string_literal: true

require 'rspec'

RSpec.describe 'UkkonenSuffixTree' do
  context 'when the text has no repeated characters' do
    it 'checks for a full match' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abc")
      tree.finalize
      expect(tree.contains?("abc")).to be true
      expect(tree.ends_with?("abc")).to be true
      expect(tree.contains?("xyz")).to be false
      expect(tree.ends_with?("xyz")).to be false
    end

    it 'checks single character matches' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abc")
      tree.finalize
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
      tree.finalize
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

  context "when the text has repeated characters" do
    it 'handles a simple one character repetition' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abca")
      tree.finalize
      expect(tree.contains?("a")).to be true
      expect(tree.contains?("ab")).to be true
      expect(tree.contains?("ca")).to be true
      expect(tree.ends_with?("a")).to be true
      expect(tree.ends_with?("ca")).to be true
      expect(tree.ends_with?("abca")).to be true
    end

    it 'handles one longer repetition' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abcabx")
      tree.finalize
      expect(tree.contains?("a")).to be true
      expect(tree.contains?("ab")).to be true
      expect(tree.contains?("abc")).to be true
      expect(tree.contains?("abx")).to be true
      expect(tree.contains?("abcx")).to be false
      expect(tree.contains?("ax")).to be false
      expect(tree.ends_with?("ab")).to be false
      expect(tree.ends_with?("abc")).to be false
      expect(tree.ends_with?("x")).to be true
      expect(tree.ends_with?("bx")).to be true
      expect(tree.ends_with?("abx")).to be true
      expect(tree.ends_with?("cabx")).to be true
    end

    it 'handles complex repetitions' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abcabxabcd")
      tree.finalize
      expect(tree.contains?("ab")).to be true
      expect(tree.contains?("abc")).to be true
      expect(tree.contains?("abx")).to be true
      expect(tree.contains?("abca")).to be true
      expect(tree.contains?("abcd")).to be true
      expect(tree.contains?("abcx")).to be false
      expect(tree.contains?("abcab")).to be true
      expect(tree.contains?("abcabx")).to be true
      expect(tree.contains?("abcabd")).to be false
      expect(tree.ends_with?("abcd")).to be true
      expect(tree.ends_with?("abc")).to be false
    end

    it 'advances the active point correctly along an edge of length 1' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abacad")
      tree.finalize
      expect(tree.contains?("ab")).to be true
      expect(tree.contains?("ac")).to be true
      expect(tree.contains?("ad")).to be true
      expect(tree.contains?("aba")).to be true
      expect(tree.contains?("aca")).to be true
    end

    it 'can properly finalize finishing on an inner node' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abcabxab")
      tree.finalize
      expect(tree.ends_with?("ab")).to be true
      expect(tree.ends_with?("cab")).to be false
      expect(tree.ends_with?("xab")).to be true
    end

    it 'can properly finalize finishing on an edge' do
      tree = ElephantInTheRoom::UkkonenSuffixTree.from("abcabcdabc")
      tree.finalize
      expect(tree.ends_with?("abc")).to be true
      expect(tree.ends_with?("abcdabc")).to be true
      expect(tree.ends_with?("abca")).to be false
      expect(tree.ends_with?("abcd")).to be false
      expect(tree.ends_with?("dabc")).to be true
    end
  end
end
