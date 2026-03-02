# frozen_string_literal: true

module ElephantInTheRoom
  module UkkonenSuffixTree
    class UkkonenSuffixTree
      class Node
        attr_reader :edges

        def initialize
          @edges = {}
        end

        def add_edge(letter, start)
          @edges[letter] = Edge.new(start)
        end
      end

      class Edge
        attr_reader :start

        def initialize(start)
          @start = start
        end
      end

      class InnerEdge < Edge
        attr_reader :to

        def initialize(to)
          @to = to
        end
      end

      def initialize
        @letters = []

        @root = Node.new
        @active_node = @root
        @active_edge = nil
        @active_length = 0
      end

      def add(text)
        text.each_char { add_letter(_1) }
      end

      def contains?(text)
        search(text, false)
      end

      def ends_with?(text)
        search(text, true)
      end

      private

      def add_letter(letter)
        @letters << letter

        @active_node.add_edge(letter, @letters.length - 1)
      end

      def search(text, must_be_suffix)
        edge = @root.edges[text[0]]
        return false unless edge
        return false if must_be_suffix && edge.is_a?(InnerEdge)
        ends_at = edge.start
        text.each_char do |l|
          if @letters[ends_at] == l
            ends_at += 1
          else
            return false
          end
        end
        !must_be_suffix || ends_at == @letters.length
      end
    end
  end
end
