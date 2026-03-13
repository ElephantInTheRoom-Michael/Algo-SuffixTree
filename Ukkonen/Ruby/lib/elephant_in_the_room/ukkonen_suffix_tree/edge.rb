class Edge
  attr_reader :start
  attr_accessor :from_node

  def initialize(start, letters)
    @start = start
    @letters = letters
  end

  def to_s
    "#{@letters[start]}@#{start}-\#"
  end

  def split(length)
    middle = @start + length
    inner_node = InnerNode.new("#{@from_node.name}(#{@letters[@start]}#{@letters[middle]})", @letters)
    left_edge = left_split(middle, inner_node)
    inner_node.from_edge = left_edge
    @from_node.add_inner_edge(left.start, left.to, inner_node)
    right_edge = right_split(middle)
    inner_node.add_edge(right_edge)
  end

  private

  def left_split(middle, inner_node)
    InnerEdge.new(@start, middle, inner_node, @letters)
  end

  def right_split(middle)
    Edge.new(middle)
  end
end

class InnerEdge < Edge
  attr_reader :to
  attr_reader :to_node

  def initialize(start, to, to_node, letters)
    super(start, letters)
    @to = to
    @to_node = to_node
  end

  def to_s
    "#{@letters[start]}@#{start}-#{@letters[to]}@#{to}"
  end

  private

  def right_split(middle)
    InnerEdge.new(middle, @to, @to_node)
  end
end
