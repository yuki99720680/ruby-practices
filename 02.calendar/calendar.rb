#!/usr/bin/env ruby

require 'date'
require 'optparse'

def generate_days_list(year, month)
  current_day = 1
  last_day = Date.new(year, month, -1).day
  days = []

  while current_day <= last_day
    date = Date.new(year, month, current_day)
    if current_day < 10
      day = format("% 2d", current_day)
    else
      day = current_day.to_s
    end
    day_of_week = date.strftime('%a')
    days << [day, day_of_week]
    current_day += 1
  end

  days
end

def console_out(days, date, today)
  puts "      #{date.month}月 #{date.year}"
  puts "日 月 火 水 木 金 土"

  space = "   "

  case days[0][1]
  when "Mon"
    print space 
  when "Tue"
    print space * 2 
  when "Wed"
    print space * 3 
  when "Thu"
    print space * 4 
  when "Fri"
    print space * 5 
  when "Sat"
    print space * 6 
  end
  
  days.each do |day, day_of_week|
    if date.year == today.year && date.month == today.month && day == today.day.to_s
      print "\e[7m" + days[i][0] + "\e[0m" + " "
    else
      print day + " "
    end
    if day_of_week == "Sat"
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

days = generate_days_list(year, month)
console_out(days, date, today)