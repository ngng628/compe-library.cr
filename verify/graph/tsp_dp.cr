# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_2_A

require "../../src/nglib/graph/tsp.cr"

n, m = read_line.split.map &.to_i64
graph = NgLib::TSPGraph(Int64).new(n)
m.times do
  u, v, w = read_line.split.map &.to_i64
  graph.add_edge(u, v, w, directed: true)
end

dp = graph.shortest_route(start: 0)
puts dp.last[0] || -1
