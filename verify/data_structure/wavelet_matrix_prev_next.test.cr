# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=1549

require "../../src/nglib/data_structure/wavelet_matrix"

_n = read_line.to_i64
wm = NgLib::CompressedWaveletMatrix.new(read_line.split.map &.to_i64)

q = read_line.to_i64
q.times do
  l, r, d = read_line.split.map &.to_i64

  ans = Int64::MAX

  pre = wm.prev_value(l..r, d)
  unless pre.nil?
    ans = {ans, (pre - d).abs}.min
  end

  nxt = wm.next_value(l..r, d)
  unless nxt.nil?
    ans = {ans, (nxt - d).abs}.min
  end

  puts ans
end
