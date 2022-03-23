#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

def main
  today = Date.today

  year = today.year
  month = today.month

  opt = OptionParser.new

  opt.on('-y YEAR') { |v| year = v.to_i }
  opt.on('-m MONTH') { |v| month = v.to_i }
  opt.parse(ARGV)

  dates = generate_dates(year, month)
  console_out(dates, today)
end

def generate_dates(year, month)
  date_from = Date.new(year, month, 1)
  date_to = Date.new(year, month, -1)

  (date_from..date_to).to_a
end

def console_out(dates, today)
  first_date = dates.first

  puts "      #{first_date.month}月 #{first_date.year}"
  puts '日 月 火 水 木 金 土'

  space = '   '

  print space * dates.first.wday

  dates.each do |date|
    if date == today
      print "\e[7m#{date.day.to_s.rjust(2)}\e[0m "
    else
      print "#{date.day.to_s.rjust(2)} "
    end

    puts '' if date.saturday?
  end
end

main
