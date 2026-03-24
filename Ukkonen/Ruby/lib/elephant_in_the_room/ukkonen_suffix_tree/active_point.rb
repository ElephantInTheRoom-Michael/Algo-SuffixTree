module ElephantInTheRoom
  module UkkonenSuffixTree
    class ActivePoint
      attr_accessor :logger
      attr_accessor :logger_redact_text

      attr_reader :node
      attr_reader :edge
      attr_reader :length

      def initialize(root, letters)
        @root = root
        @letters = letters

        @node = root
        @edge = nil
        @length = 0
      end

      def to_s
        "#{@node}#{"-#{@edge}" unless @edge.nil?}#{"@#{@length}" unless @length.zero?}"
      end

      def split_active_edge
        edge_to_split = @edge
        raise "No active edge" if edge_to_split.nil?
        edge_to_split.split(@length)
      end

      def move_after_suffix_inserted
        @logger&.info { "Move active point after suffix inserted, currently at #{self}" }
        if @node == @root
          if @length == 0
            @logger&.debug("Last edge inserted at root with no active edge, nothing to do")
          else
            @logger&.debug("Last edge inserted at root, stay at root, decrement active length, and update edge")
            @length -= 1
            edge = @edge
            if @length == 0
              edge = nil
            end
            unless edge.nil?
              edge = @root.edges[@letters[edge.start + 1]]
            end
            @edge = edge
          end
        else
          if @node.suffix_link.nil?
            @logger&.debug("No suffix link to follow, move to root, keep active edge and length the same")
          else
            @logger&.debug("Following suffix link, keep active edge and length the same")
          end
          @node = @node.suffix_link || @root
          edge = @edge
          unless edge.nil?
            @edge = @node.edges[@letters[edge.start]]
          end
        end
        @logger&.info { "Active point moved to #{self}" }
      end

      def advance_active_point(letter)
        @logger&.info { "Try to advance active point #{self}#{" with letter #{letter}" unless @logger_redact_text}" }
        initial_edge = @edge
        advanced_edge = @edge
        if initial_edge.nil?
          advanced_edge = @node.edges[letter]
          if advanced_edge.nil?
            @logger&.debug("Can not advance, no edge found")
            return false
          end
        else
          compare_letter = @letters[initial_edge.start + @length]
          if letter != compare_letter
            @logger&.debug("Can not advance#{", diverging letter is #{compare_letter}" unless @logger_redact_text}")
            return false
          end
        end

        @length += 1

        if advanced_edge.is_a?(InnerEdge) && @length == advanced_edge.to - advanced_edge.start
          @logger&.debug("Reached the end of the edge, advance to the next node")
          @node = advanced_edge.to_node
          advanced_edge = nil
          @length = 0
        end

        @edge = advanced_edge

        @logger&.info { "Advanced active point to #{self}" }

        true
      end
    end
  end
end
