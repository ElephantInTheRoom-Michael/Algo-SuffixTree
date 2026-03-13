module ElephantInTheRoom
  module UkkonenSuffixTree
    class Edge
      attr_reader :start
      attr_accessor :from_node

      def initialize(start, letters)
        @start = start
        @letters = letters
      end

      def to_s
        "#{start}#{@letters[start]}-\#"
      end

      def split(length)
        middle = @start + length
        inner_node = InnerNode.new("#{@from_node.name}(#{@letters[@start]}#{@letters[middle - 1] if (middle - 1) > start})", @letters)
        left_edge = @from_node.add_inner_edge(@start, middle, inner_node)
        inner_node.from_edge = left_edge
        add_edge_to_split_node(inner_node, middle)
        inner_node
      end

      private

      def add_edge_to_split_node(inner_node, middle)
        inner_node.add_edge(middle)
      end
    end

    class InnerEdge < Edge
      attr_reader :to
      attr_accessor :to_node

      def initialize(start, to, to_node, letters)
        super(start, letters)
        @to = to
        @to_node = to_node
      end

      def to_s
        "#{start}#{@letters[start]}-#{@letters[to - 1]}#{to}"
      end

      private

      def add_edge_to_split_node(inner_node, middle)
        inner_node.add_inner_edge(middle, @to, @to_node)
      end
    end
  end
end
