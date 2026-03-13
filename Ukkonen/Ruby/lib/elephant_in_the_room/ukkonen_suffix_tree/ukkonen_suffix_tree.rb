# frozen_string_literal: true

require_relative 'edge'
require_relative 'node'

module ElephantInTheRoom
  module UkkonenSuffixTree
    class UkkonenSuffixTree
      def initialize
        @letters = []

        @root = Node.new(@letters)
        @active_node = @root
        @active_edge = nil
        @active_length = 0
        @remainder = 0
      end

      def to_s
        @root.print_tree
      end

      def add(text)
        puts "Add #{text}"
        text.each_char { add_letter(_1) }
        puts "Completed building tree for #{@letters.join}"
      end

      # def finalize
      #   # TODO This needs to be a while loop decrementing remainder each time until it reaches 0
      #   if @active_length > 0
      #     @active_edge.split(
      #       @active_length,
      #       @letters[@active_edge.start + @active_length],
      #       EndNode.new,
      #     )
      #   # else
      #   #   @active_node.to_end_node
      #   end
      # end

      def contains?(text)
        search(text, @root, false)
      end

      # def ends_with?(text)
      #   search(text, @root, true)
      # end

      private

      def add_letter(letter)
        puts "Add letter #{letter}"

        @letters << letter

        @remainder += 1
        process_remainder
      end

      def process_remainder
        puts "Remainder starts at #{@remainder}"
        continue = true
        while @remainder > 0 && continue
          start_letter = @letters[-@remainder]
          continue = step(start_letter)
        end
        puts "Remainder ends at #{@remainder}"
      end

      def step(letter)
        puts "Step with letter #{letter} at remainder #{@remainder}"
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
          @active_node.add_edge(@letters.length - 1)
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
