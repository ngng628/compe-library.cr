# verification-helper: PROBLEM https://judge.yosupo.jp/problem/matrix_product

require "../../src/nglib/utils/fastin"
require "atcoder/mod_int"
require "matrix"

module AtCoder
  macro static_modint(name, modulo)
    module AtCoder
      # Implements atcoder::modint{{modulo}}.
      #
      # ```
      # alias Mint = AtCoder::{{name}}
      # Mint.new(30_i64) // Mint.new(7_i64)
      # ```
      struct {{name}}
        def clone
          self.class.new(@value)
        end
      end
    end
  end
end

AtCoder.static_modint(ModInt998244353, 998_244_353_i64)

alias ModInt = AtCoder::ModInt998244353

n = NgLib::FastIn::Scanner.read_i32
m = NgLib::FastIn::Scanner.read_i32
k = NgLib::FastIn::Scanner.read_i32

a = Matrix.rows(Array.new(n) { Array.new(m) { ModInt.new(NgLib::FastIn::Scanner.read_i32) } }, false)
b = Matrix.rows(Array.new(m) { Array.new(k) { ModInt.new(NgLib::FastIn::Scanner.read_i32) } }, false)

c = a * b
puts c

