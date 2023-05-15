# verification-helper: PROBLEM https://judge.yosupo.jp/problem/static_range_sum

require "../../src/nglib/data-structure/static-range-sum"

q = read_line.split.map(&.to_i32)[1]
a = read_line.split.map(&.to_i32)

csum = NgLib::StaticRangeSum.new(a.map(&.to_i64))

ans = String.build do |io|
  q.times do
    l, r = read_line.split.map(&.to_i32)
    io << csum[l...r] << '\n'
  end
end

puts ans
