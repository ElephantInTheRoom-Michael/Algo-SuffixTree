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
          @edges[letter] = Edge.new(start, self, letter)
        end

        def add_inner_edge(letter, inner_edge)
          @edges[letter] = inner_edge
        end
      end

      class EndNode < Node; end

      class Edge
        attr_reader :start

        def initialize(start, start_node, start_letter)
          @start = start
          @start_node = start_node
          @start_letter = start_letter
        end

        def split(length, at_letter, inner_node = Node.new)
          left = left_split(length)
          right = right_split(length, inner_node, at_letter)
          @start_node.add_inner_edge(@start_letter, left)
          inner_node.add_edge(at_letter, right)
          [ left, right ]
        end

        private

        def left_split(length)
          InnerEdge.new(@start, @start_node, @start_letter, @start + length, @start_node)
        end

        def right_split(length, inner_node, at_letter)
          Edge.new(@start + length, inner_node, at_letter)
        end
      end

      class InnerEdge < Edge
        attr_reader :to
        attr_reader :node

        def initialize(start, start_node, start_letter, to, node)
          super(start, start_node, start_letter)
          @to = to
          @node = node
        end

        private

        def right_split(length, inner_node, at_letter)
          InnerEdge.new(@start + length, @to, @node)
        end
      end

      def initialize
        @letters = []

        @root = Node.new
        @active_node = @root
        @active_edge = nil
        @active_length = 0
        @remainder = 0
      end

      def add(text)
        text.each_char { add_letter(_1) }
      end

      def finalize
        if @active_length > 0
          @active_edge.split(
            @active_length,
            @letters[@active_edge.start + @active_length],
            EndNode.new,
          )
        end
      end

      def contains?(text)
        search(text, @root, false)
      end

      def ends_with?(text)
        search(text, @root, true)
      end

      private

      def add_letter(letter)
        @letters << letter

        @remainder += 1
        process_remainder
      end

      def process_remainder
        continue = true
        while @remainder > 0 && continue
          start_letter = @letters[-@remainder]
          continue = step(start_letter)
        end
      end

      def step(letter)
        if @active_edge
          if letter == @letters[@active_edge.start + @active_length]
            @active_length += 1
          else
            # Split edge
          end
        elsif @active_node.edges.has_key?(letter)
          @active_edge = @active_node.edges[letter]
          @active_length = 1
        else
          @active_node.add_edge(letter, @letters.length - 1)
          @remainder = 0
        end

        false
      end

      def search(text, node, must_be_suffix)
        return true if text.empty? && (!must_be_suffix || node.is_a?(EndNode))
        edge = node.edges[text[0]]
        return false unless edge
        start = edge.start
        to = edge.is_a?(InnerEdge) ? edge.to : @letters.length
        return false if (to - start) > text.length && must_be_suffix
        (0...text.length).each do |i|
          return false if i == to - start && !edge.is_a?(InnerEdge)
          return search(text[i..], edge.node, must_be_suffix) if i == to - start
          return false if @letters[start + i] != text[i]
        end
        true
      end
    end
  end
end
