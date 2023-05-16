# verification-helper: PROBLEM https://judge.yosupo.jp/problem/point_add_range_sum

require "../../src/nglib/utils"
require "../../src/nglib/data-structure/dynamic-range-sum"

_n, q = ints
a = ints

csum = NgLib::DynamicRangeSum(Int64).new(a)

q.times do
  t, a, b = ints
  case t
  when 0
    csum.add(a, b)
  when 1
    puts csum[a...b]
  end
end
