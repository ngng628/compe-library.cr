# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_2_A

require "../../src/nglib/graph/mst"

n, m = read_line.split.map &.to_i64
graph = NgLib::MSTGraph(Int64).min(n)
m.times do
  s, t, w = read_line.split.map &.to_i64
  graph.add_edge(s, t, w)
end

puts graph.sum
