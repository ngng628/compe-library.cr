# verification-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_1_C

require "../../src/nglib/graph/floyd_warshall.cr"
require "big"

n, m = read_line.split.map &.to_i64
graph = NgLib::FloydWarshallGraph(BigInt).new(n)
m.times do
  u, v, w = read_line.split.map &.to_i64
  graph.add_edge(u, v, BigInt.new(w), directed: true)
end

d = graph.shortest_path
if n.times.any? { |i| (d[i][i] || Int64::MAX) < 0 }
  puts "NEGATIVE CYCLE"
else
  n.times do |i|
    puts d[i].map { |elem| elem || "INF" }.join ' '
  end
end
