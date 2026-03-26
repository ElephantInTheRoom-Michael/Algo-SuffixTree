require_relative "printer"

module ElephantInTheRoom
  module UkkonenSuffixTree
    class Node
      include Printer

      attr_accessor :logger
      attr_accessor :logger_redact_text

      attr_reader :name
      attr_reader :edges
      protected attr_writer :edges

      attr_accessor :suffix_link

      def initialize(letters)
        @letters = letters

        @name = "()"
        @edges = {}
      end

      def to_s
        @name
      end

      def add_edge(start)
        letter = @letters[start]
        new_edge = Edge.new(start, @letters).tap { _1.from_node = self }
        @edges[letter] = new_edge
        logger&.info("Node#{" #{self}" unless logger_redact_text} added edge#{" #{new_edge}" unless logger_redact_text}")
        new_edge
      end

      def add_inner_edge(start, to, to_node)
        letter = @letters[start]
        inner_edge = InnerEdge.new(start, to, to_node, @letters).tap { _1.from_node = self }
        @edges[letter] = inner_edge
        logger&.info("Node#{" #{self}" unless logger_redact_text} added inner edge#{" #{inner_edge}" unless logger_redact_text} to node#{" #{to_node}" unless logger_redact_text}")
        inner_edge
      end
    end

    class EndNode < Node
      def initialize(name, letters)
        super(letters)

        @name = name
      end
    end

    class InnerNode < Node
      attr_accessor :from_edge

      def initialize(name, letters)
        super(letters)

        @name = name
      end

      def replace_with_end_node
        end_node = EndNode.new("[#{@name}]", @letters)
        end_node.edges = @edges
        @from_edge.to_node = end_node
        logger&.info("Node#{" #{self}" unless logger_redact_text} is now end node#{" #{end_node}" unless logger_redact_text}")
      end
    end
  end
end
