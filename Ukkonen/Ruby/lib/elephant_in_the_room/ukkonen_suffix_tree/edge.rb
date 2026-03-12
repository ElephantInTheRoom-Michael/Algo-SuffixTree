class Edge
  attr_reader :start

  def initialize(start, start_node, start_letter)
    @start = start
    @start_node = start_node
    @start_letter = start_letter
  end

  def split(length, at_letter, inner_node = Node.new)
    left = left_split(length)
    right = right_split(length, inner_node, at_letter)
    @start_node.add_inner_edge(@start_letter, left)
    inner_node.add_edge(at_letter, right)
    [ left, right ]
  end

  private

  def left_split(length)
    InnerEdge.new(@start, @start_node, @start_letter, @start + length, @start_node)
  end

  def right_split(length, inner_node, at_letter)
    Edge.new(@start + length, inner_node, at_letter)
  end
end

class InnerEdge < Edge
  attr_reader :to
  attr_reader :node

  def initialize(start, start_node, start_letter, to, node)
    super(start, start_node, start_letter)
    @to = to
    @node = node
  end

  private

  def right_split(length, inner_node, at_letter)
    InnerEdge.new(@start + length, @to, @node)
  end
end
