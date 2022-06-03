#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/game'

marks = ARGV[0].split(',')
puts Game.new(marks).score
