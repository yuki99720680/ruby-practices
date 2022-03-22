#!/usr/bin/env ruby

require 'date'
require 'optparse'

def generate_dates_list(year, month)
  current_day = 1
  last_day = Date.new(year, month, -1).day
  dates = []

  while current_day <= last_day
    date = Date.new(year, month, current_day)
    dates << date
    current_day += 1
  end

  dates
end

def console_out(dates, today)
  puts "      #{dates[0].month}月 #{dates[0].year}"
  puts "日 月 火 水 木 金 土"

  space = "   "

  print space * dates[0].wday
  
  dates.each do |date|
    if date == today
      print "\e[7m#{date.day}\e[0m "
    else
      print "#{date.day.to_s.rjust(2)} "
    end
    if date.saturday?
      puts ""
    end
  end
end

today = Date.today

year = today.year
month = today.month

opt = OptionParser.new

opt.on('-y YEAR') {|v| year = v.to_i }
opt.on('-m MONTH') {|v| month = v.to_i }
opt.parse(ARGV)

date = Date.new(year, month, 1)

dates = generate_dates_list(year, month)
console_out(dates, today)
