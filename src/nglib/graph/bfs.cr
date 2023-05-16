require "../constants"

module NgLib
  class BfsGraph
    getter size : Int32
    getter graph : Array(Array(Int32))

    # $n$ 頂点 $0$ 辺からなるグラフを作成します。
    #
    # ```
    # graph = BfsGraph.new(n)
    # ```
    def initialize(n : Int)
      @size = n.to_i64.to_i32
      @graph = Array.new(@size) { Array(Int32).new }
    end

    # 辺 $(u, v)$ を追加します。
    #
    # `directed` が `true` の場合、
    # 有向グラフとみなして、$u$ から $v$ への辺のみ生やします。
    #
    # ```
    # graph = BfsGraph.new(n)
    # graph.add_edge(u, v)                 # => (u) <---w---> (v)
    # graph.add_edge(u, v, directed: true) # => (u) ----w---> (v)
    # ```
    def add_edge(u : Int, v : Int, directed : Bool = false)
      @graph[u.to_i32] << v.to_i32
      @graph[v.to_i32] << u.to_i32 unless directed
    end

    # 全点対間の最短経路長を返します。
    #
    # ```
    # dists = graph.shortest_path
    # dists # => [[0, 1, 3], [1, 0, 2], [1, 1, 0]]
    # ```
    def shortest_path
      (0...@size).map { |s| shortest_path(s) }
    end

    # 始点 `start` から各頂点への最短経路長を返します。
    #
    # ```
    # dist = graph.shortest_path(start: 2)
    # dist # => [3, 8, 0, 7, 1]
    # ```
    def shortest_path(start : Int)
      queue = Deque.new([start.to_i32])
      dist = Array.new(@size) { |i| i == start ? 0_i64 : OO }
      until queue.empty?
        from = queue.shift
        @graph[from].each do |to|
          next if dist[to] != OO
          dist[to] = dist[from] + 1
          queue << to
        end
      end
      dist
    end

    # 始点 `start` から終点 `dest` への最短経路長を返します。
    #
    # ```
    # dist = graph.shortest_path(start: 2, dest: 0)
    # dist # => 12
    # ```
    def shortest_path(start : Int, dest : Int)
      shortest_path(start)[dest]
    end
  end
end