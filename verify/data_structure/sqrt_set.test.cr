# verification-helper: PROBLEM https://judge.yosupo.jp/problem/predecessor_problem

require "../../src/nglib/data_structure/sortedcontainers/sqrt_set.cr"

_, q = read_line.split.map &.to_i
set = NgLib::SqrtSet(Int32).new
t = read_line.chomp.chars
t.each_with_index do |char, i|
  set << i if char == '1'
end

q.times do
  c, k = read_line.split.map &.to_i
  case c
  when 0
    set << k
  when 1
    set.delete(k)
  when 2
    puts set.includes?(k) ? 1 : 0
  when 3
    puts (set >= k) || -1
  when 4
    puts (set <= k) || -1
  end
end
