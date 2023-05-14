# verification-helper: PROBLEM https://judge.yosupo.jp/problem/lca

require "../src/nglib/graph/lca"

n, q = read_line.split.map &.to_i64
pars = read_line.split.map &.to_i64

graph = Array.new(n) { [] of Int64 }
pars.each_with_index(1) do |par, i|
  graph[i] << par
  graph[par] << i.to_i64
end

lca = NgLib::LCA.new(graph)

ans = String.build { |io|
  q.times do
    u, v = read_line.split.map &.to_i64
    io << lca.ancestor(u, v) << '\n'
  end
}

print ans
