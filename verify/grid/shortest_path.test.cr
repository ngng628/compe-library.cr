# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=0558

require "../../src/nglib/grid/grid"

struct Char
  def self.bar
    'X'
  end
end

h, _w, n = read_line.split.map &.to_i64
grid = NgLib::Grid(Char).dydx4(Array.new(h) { read_line.chomp.chars })

positions = Array({Int32, Int32}).new(n + 1) { {0, 0} }
positions[0] = grid.index!('S')
grid.each_with_coord do |chr, (i, j)|
  positions[chr.ord - '0'.ord] = {i, j} if chr.ascii_number?
end

ans = 0
positions.each_cons(2) do |(s, t)|
  ans += grid.shortest_path!({s[0], s[1]}, {t[0], t[1]})
end

puts ans
