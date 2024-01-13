# verification-helper: PROBLEM https://judge.yosupo.jp/problem/matrix_product

require "../../src/nglib/utils/fastin"
require "atcoder/mod_int"
require "matrix"

alias ModInt = AtCoder::ModInt998244353

n = NgLib::FastIn::Scanner.read_i32
m = NgLib::FastIn::Scanner.read_i32
k = NgLib::FastIn::Scanner.read_i32

a = Matrix.rows(Array.new(n) { Array.new(m) { ModInt.new(NgLib::FastIn::Scanner.read_i32) } }, false)
b = Matrix.rows(Array.new(m) { Array.new(k) { ModInt.new(NgLib::FastIn::Scanner.read_i32) } }, false)

c = a * b
puts c
