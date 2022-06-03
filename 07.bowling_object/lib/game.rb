# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(marks)
    @frames = []

    until marks.empty?
      @frames << if @frames.size == 9
                   Frame.new(*marks.shift(3))
                 elsif marks.first == 'X'
                   Frame.new(marks.shift)
                 else
                   Frame.new(*marks.shift(2))
                 end
    end
  end

  def score
    score = 0
    @frames.each_with_index do |frame, index|
      score += frame.score + add_bonus(frame, index)
    end
    score
  end

  private

  def add_bonus(frame, index)
    if index == 9
      0
    elsif frame.first_shot.strike?
      strike_bonus(index)
    elsif frame.spare?
      spare_bonus(index)
    else
      0
    end
  end

  def strike_bonus(index)
    if @frames[index + 1].second_shot.mark.nil?
      @frames[index + 1].first_shot.score + @frames[index + 2].first_shot.score
    else
      @frames[index + 1].first_shot.score + @frames[index + 1].second_shot.score
    end
  end

  def spare_bonus(index)
    @frames[index + 1].first_shot.score
  end
end
