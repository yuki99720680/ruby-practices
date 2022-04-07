#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_COUNT = 3

def main
  files = enumerate_files
  return unless files

  padded_files = add_padding(files)
  output(padded_files)
end

def enumerate_files
  path = ARGV[0] || './'

  if Dir.exist?(path)
    Dir.chdir(path) do
      Dir.glob('*')
    end
  else
    puts "ls: #{path}: No such file or directory"
  end
end

def add_padding(files)
  longgest_name = files.max_by(&:size)
  padding = longgest_name.size + 3
  files.map { |file| file.ljust(padding) }
end

def output(padded_files)
  row_count = (padded_files.size.to_f / COLUMN_COUNT).ceil
  sorted_files = Array.new(row_count) { [nil] }

  padded_files.each_with_index do |padded_file, index|
    row_index = index % row_count
    sorted_files[row_index] << padded_file
  end

  sorted_files.each do |sorted_file|
    joinned_file = sorted_file.join
    puts joinned_file unless joinned_file.empty?
  end
end

main
