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

def main
  long_format_flag = false

  opts = OptionParser.new
  opts.on('-l') { long_format_flag = true }
  opts.parse!(ARGV)

  files = enumerate_files
  return unless files

  if long_format_flag
    file_stats = build_file_stats(files)
    total_block_size = calculate_total_block_size(file_stats)
    l_option_output(total_block_size, file_stats)
  else
    basename_files = basename_files(files)
    padded_files = add_padding(basename_files)
    output(padded_files)
  end
end

def enumerate_files
  base_directory = generate_base_directory
  if Dir.exist?(base_directory)
    Dir.glob("#{base_directory}*")
  else
    puts "ls: #{base_directory}: No such file or directory"
  end
end

def build_file_stats(files)
  file_stats = []
  files.each do |file| # todo mapに置き換える
    stat = File.symlink?(file) ? File.lstat(file) : File.stat(file)
    file_info = {}
    file_info[:mode] = generate_mode(stat)
    file_info[:nlink] = stat.nlink
    file_info[:uid] = Etc.getpwuid(stat.uid).name
    file_info[:gid] = Etc.getgrgid(stat.gid).name
    file_info[:size] = stat.size
    file_info[:block] = stat.blocks
    file_info[:mtime] = stat
    file_info[:name] = File.basename(file)
    base_directory = generate_base_directory
    file_path = generate_file_path(base_directory, file_info[:name])
    file_info[:symlink] = File.readlink(file_path) if File.symlink?(file_path)
    file_stats << file_info
  end
  file_stats
end

def generate_mode(stat_raw)
  mode_characters = generate_mode_characters(stat_raw)
  mode = ''
  mode_characters.each_value do |mode_character|
    mode += mode_character
  end
  mode
end

def generate_mode_characters(stat_raw)
  mode_numbers = stat_raw.mode.to_s(8).rjust(6, '0').split(//)
  file_type = FILE_TYPE_TABLE[mode_numbers[0..1].join]
  owner_parmition = PARMITION_TABLE[mode_numbers[3]].dup
  group_parmition = PARMITION_TABLE[mode_numbers[4]].dup
  other_parmition = PARMITION_TABLE[mode_numbers[5]].dup
  owner_parmition[-1] = owner_parmition[-1] == 'x' ? 's' : 'S' if mode_numbers[2] == '4'
  group_parmition[-1] = group_parmition[-1] == 'x' ? 's' : 'S' if mode_numbers[2] == '2'
  other_parmition[-1] = other_parmition[-1] == 'x' ? 't' : 'T' if mode_numbers[2] == '1'
  { file_type: file_type, owner_parmition: owner_parmition, group_parmitio: group_parmition, other_parmition: other_parmition }
end

def calculate_total_block_size(long_format_files)
  total_block_size = 0
  base_directory = generate_base_directory
  long_format_files.each do |file| # todo sumメソッドに置き換え（条件に合致しないとき(するとき)は0を返す)
    file_path = generate_file_path(base_directory, file[:name])
    total_block_size += file[:block] if File.file?(file_path) && !File.symlink?(file_path)
  end
  total_block_size
end

def generate_base_directory
  ARGV[0] || './'
end

def generate_file_path(base_directory, file_name)
  "#{base_directory}#{file_name}"
end

def l_option_output(total_block_size, long_format_files)
  nlink_padding, uid_paddinng, gid_paddinng = calculate_padding_size(long_format_files)
  puts "total #{total_block_size}"
  long_format_files.each do |file| # todo mapに置き換える
    file_info = {}
    file_info[:mode] = file[:mode].to_s.ljust(10)
    file_info[:nlink] = file[:nlink].to_s.rjust(nlink_padding)
    file_info[:uid] = file[:uid].to_s.rjust(uid_paddinng)
    file_info[:gid] = file[:gid].to_s.rjust(gid_paddinng)
    file_info[:size] = file[:size].to_s.rjust(6)
    file_info[:mtime] = file[:mtime].mtime.strftime(' %_m %e %H:%M').to_s
    file_info[:name] = " #{file[:name]}"
    file_info[:symlink] = " -> #{file[:symlink]}" if file[:symlink]
    file_info.each_value do |f|
      print f
    end
    puts ''
  end
end

def calculate_padding_size(long_format_files)
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
