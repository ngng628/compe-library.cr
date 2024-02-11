require "atcoder/priority_queue"

module NgLib
  abstract struct Weight
    include Comparable(Weight)

    def self.zero : self
    end

    def self.inf : self
    end

    def +(other : self)
    end

    def <=>(other : self)
    end
  end

  # $n$ 頂点 $m$ 辺の重み付きグラフに対して、最短経路を求めます。
  #
  # 経路の復元も可能です。
  #
  # 辺の重みが非負整数で表せる場合は `nglib/graph/radix_dijkstra` を使ったほうが高速です。
  class DijkstraGraph(Weight)
    record Edge(W), target : Int32, weight : W

    getter size : Int32
    @graph : Array(Array(Edge(Weight)))

    # $n$ 頂点 $0$ 辺からなるグラフを作成します。
    #
    # ```
    # graph = Dijkstra.new(n)
    # ```
    def initialize(n : Int)
      @size = n.to_i32
      @graph = Array.new(@size) { Array(Edge(Weight)).new }
    end

    # 非負整数の重み $w$ の辺 $(u, v)$ を追加します。
    #
    # `directed` が `true` の場合、
    # 有向辺とみなして、$u$ から $v$ への辺のみ生やします。
    #
    # ```
    # graph = Dijkstra.new(n)
    # graph.add_edge(u, v, w)                 # => (u) <---w---> (v)
    # graph.add_edge(u, v, w, directed: true) # => (u) ----w---> (v)
    # ```
    def add_edge(u : Int, v : Int, w : Weight, directed : Bool = true)
      @graph[u.to_i32] << Edge.new(v.to_i32, w)
      @graph[v.to_i32] << Edge.new(u.to_i32, w) unless directed
    end

    # 全点対間の最短経路長を返します。
    #
    # ```
    # dists = graph.shortest_path
    # dists # => [[0, 1, 3], [1, 0, 2], [1, 1, 0]]
    # ```
    def shortest_path : Array(Array(Weight))
      (0...@size).map { |start| shortest_path(start) }
    end

    # 始点 `start` から各頂点への最短経路長を返します。
    #
    # ```
    # dist = graph.shortest_path(2)
    # dist # => [3, 8, 0, 7, 1]
    # ```
    def shortest_path(start : Int) : Array(Weight)
      dist = [Weight.inf] * @size
      dist[start] = Weight.zero
      next_node = AtCoder::PriorityQueue({Weight, Int32}).min
      next_node << {Weight.zero, start.to_i32}

      until next_node.empty?
        d, source = next_node.pop.not_nil!
        next if dist[source] < d
        @graph[source].each do |e|
          next_cost = dist[source] + e.weight
          if next_cost < dist[e.target]
            dist[e.target] = next_cost
            next_node << {next_cost, e.target}
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
    def shortest_path(start : Int, dest : Int) : Weight
      shortest_path(start)[dest]
    end

    # 始点 `start` から終点 `dest` への最短経路の一例を返します。
    #
    # ```
    # route = graph.shortest_path_route(start: 2, dest: 0)
    # route # => [2, 7, 1, 0]
    # ```
    def shortest_path_route(start, dest)
      prev = impl_memo_route(start)

      res = Array(Int32).new
      now : Int32? = dest.to_i32
      until now.nil?
        res << now.not_nil!
        now = prev[now]
      end

      res.reverse
    end

    # 始点 `start` から最短路木を構築します。
    #
    # 最短路木は `start` からの最短経路のみを残した全域木です。
    #
    # ```
    # route = graph.shortest_path_route(start: 2, dest: 0)
    # route # => [2, 7, 1, 0]
    # ```
    def shortest_path_tree(start, directed : Bool = true) : Array(Array(Int32))
      dist = [Weight.inf] * @size
      dist[start] = Weight.zero
      next_node = AtCoder::PriorityQueue({Weight, Int32}).min
      next_node << {Weight.zero, start.to_i32}

      birth = [-1] * @size
      until next_node.empty?
        d, source = next_node.pop.not_nil!
        next if dist[source] < d
        @graph[source].each do |e|
          next_cost = dist[source] + e.weight
          if next_cost < dist[e.target]
            dist[e.target] = next_cost
            next_node << {next_cost, e.target}
            birth[e.target] = source
          end
        end
      end

      tree = Array.new(@size) { [] of Int32 }
      @size.times do |target|
        source = birth[target]
        next if source == -1
        tree[source] << target
        tree[target] << source unless directed
      end

      tree
    end

    # 経路復元のための「どこから移動してきたか」を
    # メモした配列を返します。
    private def impl_memo_route(start)
      dist = [Weight.inf] * @size
      dist[start] = Weight.zero
      prev = Array(Int32?).new(@size) { nil }
      next_node = AtCoder::PriorityQueue({Weight, Int32}).min
      next_node << {Weight.zero, start.to_i32}

      until next_node.empty?
        d, source = next_node.pop.not_nil!
        next if dist[source] < d
        @graph[source].each do |e|
          next_cost = dist[source] + e.weight
          if next_cost < dist[e.target]
            dist[e.target] = next_cost
            prev[e.target] = source
            next_node << {next_cost, e.target}
          end
        end
      end

      prev
    end
  end
end
