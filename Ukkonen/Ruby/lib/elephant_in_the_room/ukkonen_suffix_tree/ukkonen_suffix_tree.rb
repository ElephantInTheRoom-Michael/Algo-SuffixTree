# frozen_string_literal: true

require_relative "edge"
require_relative "node"
require_relative "active_point"

module ElephantInTheRoom
  module UkkonenSuffixTree
    class UkkonenSuffixTree
      attr_accessor :logger
      attr_accessor :logger_redact_text

      def initialize
        @letters = []

        @root = Node.new(@letters)
        @active_point = ActivePoint.new(@root, @letters)
        @remainder = 0
      end

      def to_s
        @root.print_tree
      end

      def add(text)
        @logger&.warn("Add text to tree#{": #{text}" unless @logger_redact_text}")
        text.each_char { add_letter(_1) }
        @logger&.info { "Tree built for cumulative text#{": #{@letters.join}" unless @logger_redact_text}" }
        @logger&.warn("Tree is not ready for suffix search") if @remainder > 0
      end

      def finalize
        @logger&.info("Start finalizing tree")

        while @remainder > 0
          @logger&.info { "#{@remainder} remaining suffixes to insert at active point #{@active_point}" }

          if @active_point.length > 0
            @logger&.debug("Split active edge and insert end node")
            inner_node = @active_point.split_active_edge
            inner_node.replace_with_end_node
          else
            @logger&.debug("Replace active node with end node")
            @active_point.node.replace_with_end_node
          end

          @remainder -= 1
          @active_point.move_after_suffix_inserted
        end

        @logger&.warn("Tree is ready for suffix search")
      end

      def contains?(text)
        search(text, @root, false)
      end

      def ends_with?(text)
        search(text, @root, true)
      end

      private

      def add_letter(letter)
        @logger&.debug("Add letter#{": #{letter}" unless @logger_redact_text}")

        @letters << letter

        @remainder += 1
        process_remainder
      end

      def process_remainder
        continue = true
        last_new_node = nil
        while @remainder > 0 && continue
          @logger&.info { "#{@remainder} remaining suffixes to insert at active point #{@active_point}" }
          @logger&.debug { "Try to insert suffix#{": #{@letters[-@remainder..].join}" unless @logger_redact_text}" }
          continue, new_node = step
          if continue
            @logger&.debug("Inserted suffix")
            @remainder -= 1
            @active_point.move_after_suffix_inserted
          end
          if !last_new_node.nil? && !new_node.nil?
            @logger&.debug("Add suffix link from #{last_new_node} to #{new_node}")
            last_new_node.suffix_link = new_node
          end
          last_new_node = new_node
        end
        @logger&.info { "#{@remainder} remaining suffixes can not be inserted yet" } if @remainder > 0
      end

      def step
        letter = @letters[-1]

        new_node = nil
        add_edge = false

        unless @active_point.advance_active_point(letter)
          if @active_point.length == 0
            @logger&.debug("Create new edge")
            add_edge = true
          else
            @logger&.debug("Split active edge #{@active_edge} at length #{@active_length}")
            new_node = @active_point.split_active_edge
            add_edge = true
          end
          (new_node || @active_point.node).add_edge(@letters.length - 1)
        end

        @logger&.debug("Suffix not completely inserted") unless add_edge
        [ add_edge, new_node ]
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
