# verification-helper: PROBLEM https://judge.yosupo.jp/problem/zalgorithm

require "../../src/nglib/string/rolling_hash"

s = read_line.chomp
n = s.size

rh = NgLib::RollingHash.new(s)
a = (0...n).map { |i| rh.lcp(0, i) }
puts a.join(" ")
