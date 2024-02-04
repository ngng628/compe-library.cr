# verification-helper: PROBLEM https://judge.yosupo.jp/problem/range_kth_smallest

require "../../src/nglib/data_structure/wavelet_matrix"

_n, q = read_line.split.map &.to_i64
a = read_line.split.map &.to_i64

wm = NgLib::WaveletMatrix.new(a)

q.times do
  l, r, k = read_line.split.map &.to_i64
  puts wm.kth_smallest(l...r, k)
end
