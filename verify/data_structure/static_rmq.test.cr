# verification-helper: PROBLEM https://judge.yosupo.jp/problem/staticrmq

require "../../src/nglib/utils"
require "../../src/nglib/data_structure/sparse_table"

_n, q = ints
a = ints

rmq = NgLib::SparseTable(Int64).min(a)

q.times do
  l, r = ints
  puts rmq[l...r]
end
