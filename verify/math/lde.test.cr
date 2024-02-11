# verification-helper: PROBLEM https://onlinejudge.u-aizu.ac.jp/courses/library/6/NTL/1/NTL_1_E

require "../../src/nglib/math/lde.cr"

a, b = read_line.split.map &.to_i64
solver = NgLib::LDE(Int64).new(a, b, a.gcd(b))
x, y = solver.x!, solver.y!
puts "#{x} #{y}"
