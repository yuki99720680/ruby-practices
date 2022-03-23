#!/usr/bin/env ruby
# frozen_string_literal: true

scores = ARGV[0].split(',')

def convert_scores_to_shots(scores)
  shots = []
  scores.each do |score|
    if score == 'X' && shots.size < 18
      shots << 10 << 0
    elsif score == 'X'
      shots << 10
    else
      shots << score.to_i
    end
  end
  shots
end

def convert_shots_to_frames(shots)
  frames = shots.each_slice(2).to_a

  frames[10..].flatten unless frames[11].nil?
  frames[9..].flatten unless frames[10].nil?

  frames
end

def strike?(frame)
  frame[0] == 10
end

def spare?(frame)
  !strike?(frame) && frame.sum == 10
end

def add_bonus_for_strike(frames, frame, index)
  if index < 8 && strike?(frame) && strike?(frames[index + 1])
    frame.push(frames[index + 1][0], frames[index + 2][0])
  elsif index < 9 && strike?(frame)
    frame.push(frames[index + 1][0], frames[index + 1][1])
  end
  frame
end

def add_obnus_for_spare(frames, frame, index)
  frame.push(frames[index + 1][0]) if index < 9 && spare?(frame)
  frame
end

def convert_frames_to_bonus_added_frames(frames)
  bonus_added_frames = []
  frames.each_with_index do |frame, index|
    frame = add_bonus_for_strike(frames, frame, index)
    frame = add_obnus_for_spare(frames, frame, index)
    bonus_added_frames.push(frame)
  end
  bonus_added_frames
end

shots = convert_scores_to_shots(scores)
frames = convert_shots_to_frames(shots)
bonus_added_frames = convert_frames_to_bonus_added_frames(frames)
total_score = bonus_added_frames.sum(&:sum)
p total_score
