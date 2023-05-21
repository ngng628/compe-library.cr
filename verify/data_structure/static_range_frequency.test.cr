# verification-helper: PROBLEM https://judge.yosupo.jp/problem/static_range_frequency

require "../../src/nglib/data_structure/static_range_frequency"

_n, q = read_line.split.map &.to_i64
a = read_line.split.map &.to_i64

srf = NgLib::StaticRangeFrequency.new(a)

q.times do
  l, r, x = read_line.split.map &.to_i64
  puts srf.query(l...r, x)
end
