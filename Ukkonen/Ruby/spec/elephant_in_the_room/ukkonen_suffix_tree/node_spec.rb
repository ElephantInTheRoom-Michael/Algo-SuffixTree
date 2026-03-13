# frozen_string_literal: true

require 'rspec'

RSpec.describe 'ElephantInTheRoom::UkkonenSuffixTree::Node' do
  it 'prints nicely' do
    letters = 'abcabxabcd'.split('')
    root = ElephantInTheRoom::UkkonenSuffixTree::Node.new(letters)
    root_ab = ElephantInTheRoom::UkkonenSuffixTree::InnerNode.new("ab", letters)
    root.add_inner_edge(0, 2, root_ab)
    root_ab_c = ElephantInTheRoom::UkkonenSuffixTree::InnerNode.new("ab-c", letters)
    root_ab.add_inner_edge(2, 3, root_ab_c)
    root_ab_c.add_edge(3)
    root_ab_c.add_edge(9)
    root_ab.add_edge(5)
    root_b = ElephantInTheRoom::UkkonenSuffixTree::InnerNode.new("b", letters)
    root.add_inner_edge(1, 2, root_b)
    root_b_c = ElephantInTheRoom::UkkonenSuffixTree::InnerNode.new("b-c", letters)
    root_b.add_inner_edge(2, 3, root_b_c)
    root_b_c.add_edge(3)
    root_b_c.add_edge(9)
    root_b.add_edge(5)
    root_c = ElephantInTheRoom::UkkonenSuffixTree::InnerNode.new("c", letters)
    root.add_inner_edge(2, 3, root_c)
    root_c.add_edge(3)
    root_c.add_edge(9)
    root.add_edge(5)
    root.add_edge(9)

    expect(root.print_tree).to eq(<<~'EXP'.chomp)
    ()-ab-()-c-()-abxabcd
     |     |    \-d
     |     \-xabcd
     |-b-()-c-()-abxabcd
     |    |    \-d
     |    \-xabcd
     |-c-()-abxabcd
     |    \-d
     |-xabcd
     \-d
    EXP
  end
end
