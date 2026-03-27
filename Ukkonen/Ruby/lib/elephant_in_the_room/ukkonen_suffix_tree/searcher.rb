module ElephantInTheRoom
  module UkkonenSuffixTree
    module Searcher
      def search(text, node, must_be_suffix)
        logger&.info { "Search #{" suffix" if must_be_suffix}#{" starting at node #{node} : #{text}" unless logger_redact_text}" }

        # If arrived at a node having matched all characters...
        if text.nil? || text.empty?
          puts "Matched all text#{" at an end node" if node.is_a?(EndNode)}"
          # ... return true if it doesn't need to be a suffix, or if at an end node
          return (!must_be_suffix || node.is_a?(EndNode))
        end

        # Find the edge to search along
        edge = node.edges[text[0].to_s]
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
