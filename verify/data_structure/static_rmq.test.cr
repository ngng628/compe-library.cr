# verification-helper: PROBLEM https://judge.yosupo.jp/problem/staticrmq

require "../../src/nglib/data_structure/sparse_table"

_n, q = read_line.split.map &.to_i64
a = read_line.split.map &.to_i64

rmq = NgLib::SparseTable(Int64).min(a)

q.times do
  l, r = read_line.split.map &.to_i64
  puts rmq[l...r]
end
