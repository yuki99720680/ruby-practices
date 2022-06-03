# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/shot'

class BowlingTest < Minitest::Test
  def test_shot
    assert_equal 1, Shot.new('1').score
    assert_equal 10, Shot.new('X').score
  end
end
