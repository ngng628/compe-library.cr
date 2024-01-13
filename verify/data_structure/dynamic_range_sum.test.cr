# verification-helper: PROBLEM https://judge.yosupo.jp/problem/point_add_range_sum

require "../../src/nglib/data_structure/dynamic_range_sum"

_n, q = read_line.split.map &.to_i64
a = read_line.split.map &.to_i64

csum = NgLib::DynamicRangeSum(Int64).new(a)

q.times do
  t, a, b = read_line.split.map &.to_i64
  case t
  when 0
    csum.add(a, b)
  when 1
    puts csum[a...b]
  end
end
