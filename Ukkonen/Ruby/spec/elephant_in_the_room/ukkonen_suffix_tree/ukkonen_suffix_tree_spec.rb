# frozen_string_literal: true

require 'rspec'

RSpec.describe 'UkkonenSuffixTree' do
  it 'checks for a full match' do
    expect(ElephantInTheRoom::UkkonenSuffixTree.from("text").contains("text")).to be true
    expect(ElephantInTheRoom::UkkonenSuffixTree.from("text").contains("word")).to be false
  end
end
