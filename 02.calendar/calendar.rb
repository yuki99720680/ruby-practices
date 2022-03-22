#!/usr/bin/env ruby

require 'date'
require 'optparse'

def generate_dates_list(year, month)
  last_day = Date.new(year, month, -1).day
  dates = []

  (1..last_day).each do |day|
    date = Date.new(year, month, day)
    dates << date
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

    puts "" if date.saturday?
  end
end

today = Date.today

year = today.year
month = today.month

opt = OptionParser.new

opt.on('-y YEAR') {|v| year = v.to_i }
opt.on('-m MONTH') {|v| month = v.to_i }
opt.parse(ARGV)

dates = generate_dates_list(year, month)
console_out(dates, today)
