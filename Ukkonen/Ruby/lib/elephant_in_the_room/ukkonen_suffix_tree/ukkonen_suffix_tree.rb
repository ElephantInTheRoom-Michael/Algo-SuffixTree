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

      class EndNode < Node; end

      class Edge
        attr_reader :start

        def initialize(start)
          @start = start
        end
      end

      class InnerEdge < Edge
        attr_reader :to
        attr_reader :node

        def initialize(start, to, node)
          super(start)
          @to = to
          @node = node
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
        if @remainder > 0
          split_active_edge(EndNode.new)
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
          continue = step
        end
      end

      def step
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

      def split_active_edge(inner_node)
        right_edge = Edge.new(@active_edge.start + @active_length)
        left_edge = InnerEdge.new(@active_edge.start, right_edge.start, inner_node)
        @active_node.edges[@letters[left_edge.start]] = left_edge
        inner_node.edges[@letters[right_edge.start]] = right_edge
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
