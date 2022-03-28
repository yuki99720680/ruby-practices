#!/usr/bin/env ruby
# frozen_string_literal: true

path = if ARGV[0].nil?
         './'
       else
         ARGV[0]
       end

begin
  Dir.chdir(path)
rescue Errno::ENOENT
  puts "ls: #{path}: No such file or directory"
  exit
end

dirs = Dir.glob('*')

longgest_text = dirs.max_by(&:size)
padding = longgest_text.size + 3
dirs.map! { |dir| dir.ljust(padding) }

outs = [[nil], [nil], [nil]]

dirs.each_with_index do |dir, index|
  outs[0] << dir if (index % 3).zero?
  outs[1] << dir if index % 3 == 1
  outs[2] << dir if index % 3 == 2
end

outs.map!(&:join)

outs.each do |out|
  puts out unless out.empty?
end
