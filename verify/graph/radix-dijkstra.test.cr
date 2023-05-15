# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_1_A

require "../../src/nglib/graph/radix-dijkstra-graph"
require "../../src/nglib/constants"

n, m, r = read_line.split.map &.to_i64
graph = NgLib::DijkstraGraph.new(n)
m.times do
  u, v, w = read_line.split.map &.to_i64
  graph.add_edge(u, v, w, directed: true)
end

dist = graph.shortest_path(start: r)
n.times do |i|
  puts dist[i] >= OO ? "INF" : dist[i]
end
