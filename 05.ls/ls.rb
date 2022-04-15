#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMN_COUNT = 3
FILE_TYPE_TABLE = {
  '01' => 'p',
  '02' => 'c',
  '04' => 'd',
  '06' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze
PARMITION_TABLE = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze
SPECIAL_PARMITION_TABLE = {
  '1' => 't',
  '2' => 's',
  '4' => 's'
}.freeze

def main
  long_format_flag = false

  opts = OptionParser.new
  opts.on('-l') { long_format_flag = true }
  opts.parse!(ARGV)

  files = enumerate_files
  return unless files

  if long_format_flag # ここらのメソッドを束ねて、三項演算子で読み出す
    long_format_files = add_stats(files)
    total_block_size = calculate_total_block_size(long_format_files)
    padded_files = l_option_add_padding(long_format_files) # TODO; Refact
    l_option_output(total_block_size, padded_files)
  else
    basename_files = basename_files(files)
    padded_files = add_padding(basename_files)
    output(padded_files)
  end
end

private

def enumerate_files
  path = ARGV[0] || './'

  if Dir.exist?(path)
    Dir.glob("#{path}*")
  else
    puts "ls: #{path}: No such file or directory"
  end
end

def add_stats(files)
  long_format_files = []
  files.each do |file|
    stat = {}
    stat[:mode] = generate_mode(file)
    stat[:nlink] = File.stat(file).nlink
    stat[:uid] = Etc.getpwuid(File.stat(file).uid).name
    stat[:gid] = Etc.getgrgid(File.stat(file).gid).name
    stat[:size] = File.stat(file).size
    stat[:block] = File.stat(file).blocks
    stat[:mtime] = File.stat(file)
    stat[:name] = File.basename(file)
    stat[:symlink] = File.readlink(stat[:name]) if File.symlink?(stat[:name])
    long_format_files << stat
  end
  long_format_files
end

def generate_mode(file)
  mode_numbers = File.stat(file).mode.to_s(8).rjust(6, '0').split(//)
  mode_characters = {}
  mode_characters[:file_type] = FILE_TYPE_TABLE[mode_numbers[0..1].join]
  mode_characters[:owner_parmition] = PARMITION_TABLE[mode_numbers[3]]
  mode_characters[:group_parmition] = PARMITION_TABLE[mode_numbers[4]]
  other_parmition = PARMITION_TABLE[mode_numbers[5]].dup
  special_parmition = SPECIAL_PARMITION_TABLE[mode_numbers[2]]
  other_parmition[-1] = other_parmition[-1] == 'x' ? special_parmition : special_parmition.upcase if special_parmition
  mode_characters[:other_parmition] = other_parmition
  mode = ''
  mode_characters.each_value do |mode_character|
    mode += mode_character
  end
  mode
end

def calculate_total_block_size(long_format_files)
  total_block_size = 0
  long_format_files.each do |file|
    total_block_size += file[:block] if File.file?(file[:name]) && !File.symlink?(file[:name])
  end
  total_block_size
end

def l_option_add_padding(long_format_files) # TODO; Refact
  nlink_padding, uid_paddinng, gid_paddinng = calculate_padding_size(long_format_files)
  formated_files = []
  long_format_files.each do |file|
    stat = {}
    stat[:mode] = file[:mode].to_s.ljust(10)
    stat[:nlink] = file[:nlink].to_s.rjust(nlink_padding)
    stat[:uid] = file[:uid].to_s.rjust(uid_paddinng)
    stat[:gid] = file[:gid].to_s.rjust(gid_paddinng)
    stat[:size] = file[:size].to_s.rjust(6)
    stat[:mtime] = file[:mtime].mtime.strftime(' %_m %e %H:%M').to_s
    stat[:name] = " #{file[:name]}"
    stat[:symlink] = " -> #{file[:symlink]}" if file[:symlink]
    formated_files << stat
  end

  formated_files
end

def calculate_padding_size(long_format_files) # TODO; Refact
  nlink_sizes = []
  uid_sizes = []
  gid_sizes = []
  long_format_files.each do |file|
    nlink_sizes << file[:nlink].to_s.size
    uid_sizes << file[:uid].to_s.size
    gid_sizes << file[:gid].to_s.size
  end
  nlink_padding = nlink_sizes.max + 2
  uid_paddinng = uid_sizes.max + 1
  gid_paddinng = gid_sizes.max + 2
  [nlink_padding, uid_paddinng, gid_paddinng]
end

def l_option_output(total_block_size, padded_files)
  puts "total #{total_block_size}"
  padded_files.each do |file|
    file.each_value do |f|
      print f
    end
    puts ''
  end
end

def basename_files(files)
  basename_files = []
  files.each do |file|
    basename_files << File.basename(file)
  end
  basename_files
end

def add_padding(basename_files)
  longgest_name = basename_files.max_by(&:size)
  padding = longgest_name.size + 3
  basename_files.map { |file| file.ljust(padding) }
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
