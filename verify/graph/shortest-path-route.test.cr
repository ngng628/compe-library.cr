# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_1_A

require "../../src/nglib/utils"
require "../../src/nglib/graph/radix-dijkstra-graph"
require "../../src/nglib/constants"

n, m, s, t = ints
graph = NgLib::DijkstraGraph.new(n)
m.times do
  a, b, c = ints
  graph.add_edge(a, b, c, directed: true)
end

dist = graph.shortest_path(start: s, dest: t)

if dist >= OO
  puts -1
  exit
end

path = graph.shortest_path_route(start: s, dest: t)

puts "#{dist} #{path.size - 1}"
path.each_cons(2) do |(u, v)|
  puts "#{u} #{v}"
end
