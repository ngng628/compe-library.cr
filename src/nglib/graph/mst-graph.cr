require "atcoder/dsu"

module NgLib
  # $n$ 頂点の重み付きグラフについて、最小/最大全域木を構築します。
  #
  # Kruskal 法による実装です。
  class MSTGraph(T)
    getter size : Int64
    @edges : Array({Int32, Int32, T})

    def initialize(n)
      @size = n.to_i64
      @edges = [] of {Int32, Int32, T}
      @cmp = ->(a : T, b : T) { a <=> b }
    end

    def initialize(n, &@cmp : (T, T) -> Int32)
      @size = n.to_i64
      @edges = [] of {Int32, Int32, T}
    end

    # $n$ 頂点 $0$ 辺のグラフを生成します。
    #
    # 最小全域木を構築します。
    def self.min(n)
      new(n) { |a, b| a <=> b }
    end

    # $n$ 頂点 $0$ 辺のグラフを生成します。
    #
    # 最大全域木を構築します。
    def self.max(n)
      new(n) { |a, b| b <=> a }
    end

    # グラフに辺 $(u, v, w)$ を追加します。
    #
    # ```
    # graph = MSTGraph(Int64).new(n) { |a, b| a < b }
    # m.times { graph.add_edge(u, v, w) }
    # ```
    def add_edge(u : Int, v : Int, w : T)
      @edges << {u.to_i32, v.to_i32, w}
    end

    # 最小全域木を構成したときの辺の重みの総和求めます。
    #
    # ```
    # graph = MSTGraph(Int64).new(n) { |a, b| a < b }
    # m.times { graph.add_edge(u, v, w) }
    # graph.sum
    # ```
    def sum
      @edges.sort! { |a, b| @cmp.call(a[2], b[2]) }
      ut = AtCoder::DSU.new(@size)
      res = T.zero
      @edges.each do |(u, v, w)|
        next if ut.same?(u, v)
        ut.merge(u, v)
        res += w
      end
      res
    end
  end
end
