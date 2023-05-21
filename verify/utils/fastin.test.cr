# verification-helper: PROBLEM https://judge.yosupo.jp/problem/many_aplusb

require "../../src/nglib/utils/fastin"

t = NgLib::FastIn::Scanner.read_i32

ans = String.build { |io|
  t.times do
    a = NgLib::FastIn::Scanner.read_i64
    b = NgLib::FastIn::Scanner.read_i64
    io << a + b << '\n'
  end
}

print ans
