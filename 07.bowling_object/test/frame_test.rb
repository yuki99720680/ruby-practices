# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/frame'

class BowlingTest < Minitest::Test
  def test_frame
    assert_equal 1, Frame.new('1').score
    assert_equal 3, Frame.new('1', '2').score
    assert_equal 13, Frame.new('1', '2', 'X').score
  end
end
