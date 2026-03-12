class Node
  attr_reader :edges

  def initialize
    @edges = {}
  end

  def add_edge(letter, start)
    @edges[letter] = Edge.new(start, self, letter)
  end

  def add_inner_edge(letter, inner_edge)
    @edges[letter] = inner_edge
  end
end

class EndNode < Node; end
