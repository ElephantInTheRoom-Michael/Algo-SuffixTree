module ElephantInTheRoom
  module UkkonenSuffixTree
    module Searcher
      def search(cs, node, must_be_suffix)
        logger&.info { "Search remaining #{cs.length} characters #{" as a suffix" if must_be_suffix}#{" starting at node #{node}" unless logger_redact_text}" }

        result = check_end_of_search_string(cs, node, must_be_suffix)
        return result unless result.nil?

        edge = edge_to_search(cs, node)
        return false if edge.nil?

        edge_length = edge_length_to_search(cs, edge, must_be_suffix)
        return false if edge_length.nil?

        (0...[ cs.length, edge_length ].min).each do |i|
          letter = @letters[edge.start + i]
          if letter != cs[i]
            puts "Search for #{cs[i]} failed finding #{letter}"
            return false
          end
        end

        next_search_text = cs[edge_length..] || []
        unless edge.is_a?(InnerEdge)
          puts "On a leaf edge so search must conclude"
          if cs.length == edge_length
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

      private

      def check_end_of_search_string(cs, node, must_be_suffix)
        # If arrived at a node having previously matched all characters...
        if cs.empty?
          logger&.debug { "Matched all search text#{" at an end node" if node.is_a?(EndNode)}" }
          # ... return match if it doesn't need to be a suffix, or if at an end node
          return (!must_be_suffix || node.is_a?(EndNode))
        end

        nil
      end

      def edge_to_search(cs, node)
        edge = node.edges[cs.first]
        if edge.nil?
          logger&.debug { "No matching edge to follow" }
          return nil
        end

        logger&.debug { "Search along edge #{edge}" } unless edge.nil?
        edge
      end

      def edge_length_to_search(cs, edge, must_be_suffix)
        # Get the range to search along this edge...
        start = edge.start
        to = edge.is_a?(InnerEdge) ? edge.to : @letters.length
        edge_length = to - start

        # ... and verify the range of available text to search is compatible with search text
        if edge_length > cs.length && must_be_suffix
          logger&.debug { "Edge was too long to match text as a suffix" }
          return nil
        end
        if edge_length < cs.length && !edge.is_a?(InnerEdge)
          logger&.debug { "Text was longer than leaf edge" }
          return nil
        end

        edge_length
      end
    end
  end
end
