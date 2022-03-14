require 'date'
require 'optparse'

opt = OptionParser.new

today = Date.today
year = today.year
month = today.month

opt.on('-y YEAR') {|v| year = v.to_i }
opt.on('-m MONTH') {|v| month = v.to_i }
opt.parse(ARGV)

date = Date.new(year, month, -1)

current_day = 1
last_day = date.day

days = []

while current_day <= last_day
  date = Date.new(year, month, current_day)
  if current_day < 10
    day1 = format("% 2d", current_day)
  else
    day1 = current_day.to_s
  end
  day2 = date.strftime('%a')
  days << [day1, day2]
  current_day += 1
end

puts "      #{month}月 #{year}"
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

for i in 0..days.length-1 do
  if date.year == today.year && date.month == today.month && days[i][0] == today.day.to_s
    print "\e[7m" + days[i][0] + "\e[0m" + " "
  else
    print days[i][0] + " "
  end
  if days[i][1] == "Sat"
    puts ""
  end
end