

dirs = Dir.glob('*')

longgest_text = dirs.max_by { |x| x.size }
padding = longgest_text.size + 3
dirs.map! { |dir| dir.ljust(padding) }

outs = [[], [], []]

dirs.each_with_index do |dir, index|
  outs[0] << dir if (index % 3).zero?
  outs[1] << dir if index % 3 == 1
  outs[2] << dir if index % 3 == 2
end

outs.map!(&:join)

puts outs