# frozen_string_literal: true

require_relative "edge"
require_relative "node"

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

      def finalize
        puts "Finalize"

        while @remainder > 0
          puts "Remainder #{@remainder}"
          if @active_length > 0
            puts "On active edge #{@active_edge} at length #{@active_length}"
            inner_node = @active_edge.split(@active_length)
            inner_node.replace_with_end_node
          else
            puts "On active node #{@active_node}"
            @active_node.replace_with_end_node
          end

          @remainder -= 1
          reset_active_point
          rescan if @remainder > 0
        end

        puts self
      end

      def contains?(text)
        search(text, @root, false)
      end

      def ends_with?(text)
        search(text, @root, true)
      end

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
        if @active_length > 0
          unless advance_active_point(letter)
            puts "Split edge #{@active_edge} at length #{@active_length}"
            node = @active_edge.split(@active_length)

            node.add_edge(@letters.length - 1)

            return true
          end
        elsif @active_node.edges.has_key?(letter)
          puts "Found existing edge"
          advance_active_point(letter)
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
        (0...(@remainder)).each do |i|
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
          @active_edge = nil
          @active_length = 0
        end

        puts "Advanced active point to #{@active_node} with edge #{@active_edge} and length #{@active_length}"

        true
      end

      def search(text, node, must_be_suffix)
        puts "Search #{text}#{" suffix" if must_be_suffix} starting at node #{node}"

        # If arrived at a node having matched all characters...
        if text.nil? || text.empty?
          puts "Matched all text#{" at an end node" if node.is_a?(EndNode)}"
          # ... return true if it doesn't need to be a suffix, or if at an end node
          return (!must_be_suffix || node.is_a?(EndNode))
        end

        # Find the edge to search along
        edge = node.edges[text[0]]
        return false unless edge
        puts "Search along edge #{edge}"

        # Get the range to search along this edge
        start = edge.start
        to = edge.is_a?(InnerEdge) ? edge.to : @letters.length
        if must_be_suffix && (to - start) > text.length
          puts "Edge was too long to match text as a suffix"
          return false
        end

        if (to - start) < text.length && !edge.is_a?(InnerEdge)
          puts "Text was longer than leaf edge"
          return false
        end

        (0...[ text.length, to - start ].min).each do |i|
          if @letters[start + i] != text[i]
            puts "Search for #{text[i]} failed finding #{@letters[start + 1]}"
            return false
          end
        end

        next_search_text = text[(to - start)..]
        unless edge.is_a?(InnerEdge)
          puts "On a leaf edge so search must conclude"
          if text.length == (to - start)
            puts "Matched all text to end of leaf edge"
            return true
          end
          if must_be_suffix
            puts "Text did not match to end of leaf edge"
            return false
          end
          return true
        end

        search(next_search_text, edge.to_node, must_be_suffix)
      end
    end
  end
end
