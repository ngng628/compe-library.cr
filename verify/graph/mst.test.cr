# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_2_A

require "../../src/nglib/utils"
require "../../src/nglib/graph/mst"

n, m = ints
graph = NgLib::MSTGraph(Int64).min(n)
m.times do
  s, t, w = ints
  graph.add_edge(s, t, w)
end

puts graph.sum
