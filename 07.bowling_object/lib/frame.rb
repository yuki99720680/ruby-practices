# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :first_shot, :second_shot

  def initialize(first_mark, second_mark = nil, third_mark = nil)
    @first_shot = Shot.new(first_mark)
    @second_shot = Shot.new(second_mark)
    @third_shot = Shot.new(third_mark)
  end

  def score
    @first_shot.score + @second_shot.score + @third_shot.score
  end

  def spare?
    !include_strike? && (@first_shot.score + @second_shot.score == 10 || @second_shot.score + @third_shot.score == 10)
  end

  private

  def include_strike?
    @first_shot.strike? || @second_shot.strike? || @third_shot.strike?
  end
end
