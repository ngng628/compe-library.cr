require "../constants"

module NgLib
  class BinaryBfsGraph
    private struct Edge
      getter to : Int32
      getter weight : Int32

      def initialize(t : Int, w : Int)
        @to = t.to_i32
        @weight = w.to_i32
      end
    end

    getter size : Int32
    getter graph : Array(Array(Edge))

    # $n$ 頂点 $0$ 辺からなるグラフを作成します。
    #
    # ```
    # graph = BfsGraph.new(n)
    # ```
    def initialize(n : Int)
      @size = n.to_i64.to_i32
      @graph = Array.new(@size) { [] of Edge }
    end

    # 辺 $(u, v, w)$ を追加します。
    #
    # $w$ は $0$ または $1$ である必要があります。
    #
    # `directed` が `true` の場合、
    # 有向辺とみなして、$u$ から $v$ への辺のみ生やします。
    #
    # ```
    # graph = BfsGraph.new(n)
    # graph.add_edge(u, v)                 # => (u) <---w---> (v)
    # graph.add_edge(u, v, directed: true) # => (u) ----w---> (v)
    # ```
    def add_edge(u : Int, v : Int, w : Int, directed : Bool = false)
      raise Exception.new("w should be 0 or 1") unless w.in?({0, 1})
      @graph[u.to_i32] << Edge.new(v, w)
      @graph[v.to_i32] << Edge.new(u, w) unless directed
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
      deque = Deque.new([start.to_i32])
      dist = Array.new(@size) { |i| i == start ? 0_i64 : OO }
      until deque.empty?
        from = deque.shift
        @graph[from].each do |e|
          d = dist[from] + e.weight
          if d < dist[e.to]
            dist[e.to] = d
            if e.weight == 0
              deque.unshift(e.to)
            else
              deque << e.to
            end
          end
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
