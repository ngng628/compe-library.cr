# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_1_A

require "../src/nglib/graph/dijkstra-graph.cr"
require "../src/nglib/constants"

struct W < NgLib::Weight
  getter weight : Int64

  def initialize(@weight)
  end

  def self.zero
    W.new(0_i64)
  end

  def self.inf
    W.new(OO)
  end

  def +(other : self)
    W.new(Math.min(@weight + other.weight, OO))
  end

  def <=>(other : self)
    weight <=> other.weight
  end
end

n, m, r = read_line.split.map &.to_i64
graph = NgLib::DijkstraGraph(W).new(n)
m.times do
  a, b, c = read_line.split.map &.to_i64
  graph.add_edge(a, b, W.new(c), directed: true)
end

dist = graph.shortest_path(start: r)

n.times do |i|
  puts dist[i] >= W.inf ? "INF" : dist[i].weight
end
