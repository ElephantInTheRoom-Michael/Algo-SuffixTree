require_relative 'printer'

module ElephantInTheRoom
  module UkkonenSuffixTree
    class Node
      include Printer

      attr_reader :name
      attr_reader :edges

      def initialize(letters)
        @letters = letters

        @name = ""
        @edges = {}
      end

      def to_s
        "@#{@name}@"
      end

      def add_edge(start)
        letter = @letters[start]
        @edges[letter] = Edge.new(start, @letters).tap { _1.from_node = self }
        puts "Node #{self} added edge #{letter}: #{@edges[letter]}"
        @edges[letter]
      end

      def add_inner_edge(start, to, to_node)
        letter = @letters[start]
        @edges[letter] = InnerEdge.new(start, to, to_node, @letters).tap { _1.from_node = self }
        puts "Node #{self} added inner edge #{letter} to node #{to_node}: #{@edges[letter]}"
        @edges[letter]
      end

      def set_all_edges(edges)
        @edges = edges
      end
    end

    class EndNode < Node
      def initialize(name, letters)
        super(letters)

        @name = name
      end

      def to_s
        "#{super}/"
      end
    end

    class InnerNode < Node
      attr_accessor :from_edge

      def initialize(name, letters)
        super(letters)

        @name = name
      end

      def to_s
        "@#{@name}@"
      end

      def replace_with_end_node
        "Node #{self} replaced with end node"

        end_node = EndNode.new(@name, @letters)

        end_node.set_all_edges(@edges)

        @from_edge.to_node = end_node
      end
    end
  end
end
