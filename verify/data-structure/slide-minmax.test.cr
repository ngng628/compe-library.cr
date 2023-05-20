# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DSL_3_D

require "../../src/nglib/data-structure/slide-minmax"

n, l = read_line.split.map &.to_i
a = read_line.split.map &.to_i

rmq = NgLib::SlideMinmax(Int32).min(a, length: l)
ans = String.build { |io|
  (n - l + 1).times do |i|
    io << rmq.query(i) << (i < n - l ? ' ' : '\n')
  end
}

print ans
