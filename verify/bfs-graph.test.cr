# verification-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=ALDS1_11_C

require "../src/nglib/graph/bfs"

n = read_line.to_i64
graph = NgLib::BfsGraph.new(n)
n.times do
  line = read_line.split.map &.to_i64.pred
  u = line[0]
  vs = line[2...]

  vs.each do |v|
    graph.add_edge(u, v, directed: true)
  end
end

dist = graph.shortest_path(start: 0)

n.times do |i|
  puts "#{i + 1} #{dist[i] >= n + 1 ? -1 : dist[i]}"
end
