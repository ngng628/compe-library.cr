# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_6_A

require "../../src/nglib/graph/max-flow"

n, m = read_line.split.map &.to_i

graph = NgLib::MaxFlowGraph(Int32).new(n)
m.times do
  u, v, c = read_line.split.map &.to_i
  graph.add_edge(u, v, c)
end

ans = graph.flow(0, n - 1)
puts ans
