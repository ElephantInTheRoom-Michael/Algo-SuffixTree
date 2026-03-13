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
        puts self
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
          puts "Remainder #{@remainder}"
          continue = step
          if continue
            @remainder -= 1
            reset_active_point
            rescan if @remainder > 0
          end
        end
        puts "Remainder ends at #{@remainder}"
      end

      def step
        letter = @letters[-1]
        if @active_edge
          unless advance_active_point(letter)
            puts "Split edge #{@active_edge} at length #{@active_length}"
            node = @active_edge.split(@active_length)

            node.add_edge(@letters.length - 1)

            return true
          end
        elsif @active_node.edges.has_key?(letter)
          puts "Found existing edge"
          @active_edge = @active_node.edges[letter]
          @active_length = 1
        else
          puts "Create new edge"
          @active_node.add_edge(@letters.length - 1)
          return true
        end

        puts "Suffix not completely inserted"
        false
      end

      def reset_active_point
        puts "Reset active point"
        @active_node = @root
        @active_edge = nil
        @active_length = 0
      end

      def rescan
        puts "Rescan"
        (0...(@remainder - 1)).each do |i|
          letter = @letters[-(@remainder - i)]
          advance_active_point(letter)
        end
      end

      def advance_active_point(letter)
        puts "Try to advance active point with letter #{letter}"
        if @active_length == 0
          @active_edge = @active_node.edges[letter]
          if @active_edge.nil?
            puts "Can not advance, no edge found"
            return false
          end
        else
          compare_letter = @letters[@active_edge.start + @active_length]
          if letter != compare_letter
            puts "Can not advance, diverging letter is #{compare_letter}"
            return false
          end
        end

        @active_length += 1

        if @active_edge.is_a?(InnerEdge) && @active_length == @active_edge.to - @active_edge.start
          @active_node = @active_edge.to_node
          @active_length = 0
        end

        puts "Advanced active point to #{@active_node} with edge #{@active_edge} and length #{@active_length}"

        true
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
          return search(text[i..], edge.to_node, must_be_suffix) if i == to - start
          return false if @letters[start + i] != text[i]
        end
        true
      end
    end
  end
end
