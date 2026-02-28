# frozen_string_literal: true

module ElephantInTheRoom
  module UkkonenSuffixTree
    class UkkonenSuffixTree
      attr_reader :letters

      def initialize
        @letters = []
      end

      def add(text)
        text.each_char { |letter| add_letter(letter) }
      end

      def contains(text)
        @letters.join == text
      end

      private

      def add_letter(letter)
        @letters << letter
      end
    end
  end
end
