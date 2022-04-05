#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_COUNT = 3

def main
  specify_path
  dirs = Dir.glob('*')
  dirs2 = add_padding(dirs)
  output(dirs2)
end

def specify_path
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
end

def add_padding(dirs)
  longgest_name = dirs.max_by(&:size)
  padding = longgest_name.size + 3
  dirs.map { |dir| dir.ljust(padding) }
end

def output(dirs)
  height = (dirs.size.to_f / COLUMN_COUNT).ceil
  outs = Array.new(height) { [nil] }

  dirs.each_with_index do |dir, index|
    excess = index % height
    outs[excess] << dir
  end

  outs2 = outs.map(&:join)

  outs2.each do |out|
    puts out unless out.empty?
  end
end

main
