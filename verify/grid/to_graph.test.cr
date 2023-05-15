# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=1160

require "../../src/nglib/grid/grid"
require "atcoder/dsu"

struct Int
  def self.bar
    self.zero
  end
end

answers = String.build { |io|
  loop do
    w, h = read_line.split.map &.to_i64
    break if (w | h) == 0
    s = (1..h).map { read_line.split.map &.to_i64 }
    grid = NgLib::Grid(Int64).dydx8(s)

    label = grid.label_grid

    ans = label.max + 1
    io << ans << '\n'
  end
}

print answers
