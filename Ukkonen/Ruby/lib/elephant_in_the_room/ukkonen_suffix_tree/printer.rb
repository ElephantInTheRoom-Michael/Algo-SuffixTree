module ElephantInTheRoom
  module UkkonenSuffixTree
    module Printer
      def print_tree
        print_node
      end

      private

      def print_node
        lines = []

        @edges.values.each do |edge|
          printed_edge = print_edge(edge)
          if edge.is_a? InnerEdge
            edge.to_node.print_tree.each_line.with_index do |node_line, node_line_number|
              line = node_line_number == 0 ? printed_edge : " ".ljust(printed_edge.length)
              line += node_line.chomp
              lines.append(line)
            end
          else
            lines.append(printed_edge)
          end
        end

        lines.append("") if lines.empty?
        lines.each.with_index do |line, line_number|
          prefix = if line_number == 0
                     "()"
                   elsif line_number == lines.length - 1
                     " \\"
                   else
                     " |"
                   end

          lines[line_number] = "#{prefix}#{line}"
        end
        lines.join("\n")
      end

      def print_edge(edge)
        s = "-"

        first_letter = edge.start
        last_letter = if edge.is_a? InnerEdge
                        edge.to
                      else
                        @letters.length
                      end
        (first_letter...last_letter).each do |i|
          s += @letters[i]
        end

        if edge.is_a? InnerEdge
          s += "-"
        end

        s
      end
    end
  end
end
