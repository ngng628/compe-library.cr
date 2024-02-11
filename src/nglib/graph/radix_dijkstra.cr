require "../constants.cr"

module NgLib
  # $n$ 頂点 $m$ 辺の重み付きグラフに対して、最短経路を求めます。
  #
  # 経路の復元も可能です。
  #
  # このクラスは辺の重みが非負整数であるときのみ使えます。
  # 辺の重みに非負整数以外を使いたい場合は `nglib/graph/dijkstra` を `require` してください。
  class DijkstraGraph
    record Edge, target : Int32, weight : UInt64

    # 基数ヒープ
    private class RadixHeap64(T)
      @s : Int32
      @last : UInt64
      @bit : Int32
      @vs : Array(Array({UInt64, T}))
      @ms : Array(UInt64)

      def initialize
        @s = 0
        @last = 0_u64
        @bit = sizeof(UInt64) * 8
        @vs = Array.new(@bit + 1) { [] of {UInt64, T} }
        @ms = Array.new(@bit + 1) { -1.to_u64! }
      end

      def empty? : Bool
        @s == 0
      end

      def size : Int32
        s
      end

      @[AlwaysInline]
      def get_bit(x : UInt64) : UInt64
        64_u64 - x.leading_zeros_count
      end

      def push(key : UInt64, val : T) : Nil
        @s += 1
        b = get_bit(key ^ @last)
        @vs[b] << {key, val}
        @ms[b] = Math.min(@ms[b], key)
      end

      def pop : {UInt64, T}
        if @ms[0] == -1.to_u64!
          idx = @ms.index! { |elem| elem != -1.to_u64! }
          @last = @ms[idx]
          @vs[idx].each do |v|
            b = get_bit(v[0] ^ @last)
            @vs[b] << v
            @ms[b] = Math.min(@ms[b], v[0])
          end
          @vs[idx].clear
          @ms[idx] = -1.to_u64!
        end

        @s -= 1
        res = @vs[0].last
        @vs[0].pop
        @ms[0] = -1.to_u64! if @vs[0].empty?

        res
      end
    end

    getter size : Int32
    @graph : Array(Array(Edge))

    # $n$ 頂点 $0$ 辺からなるグラフを作成します。
    #
    # ```
    # graph = Dijkstra.new(n)
    # ```
    def initialize(n : Int)
      @size = n.to_i32
      @graph = Array.new(@size) { Array(Edge).new }
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
    def add_edge(u : Int, v : Int, w : Int, directed : Bool = true)
      @graph[u.to_i32] << Edge.new(v.to_i32, w.to_u64)
      @graph[v.to_i32] << Edge.new(u.to_i32, w.to_u64) unless directed
    end

    # 全点対間の最短経路長を返します。
    #
    # ```
    # dists = graph.shortest_path
    # dists # => [[0, 1, 3], [1, 0, 2], [1, 1, 0]]
    # ```
    def shortest_path
      (0...@size).map { |start| shortest_path(start) }
    end

    # 始点 `start` から各頂点への最短経路長を返します。
    #
    # ```
    # dist = graph.shortest_path(2)
    # dist # => [3, 8, 0, 7, 1]
    # ```
    def shortest_path(start : Int)
      dist = [OO] * @size
      dist[start] = 0_i64
      next_node = RadixHeap64(Int32).new
      next_node.push(0_u64, start.to_i32)

      until next_node.empty?
        d, source = next_node.pop
        next if dist[source] < d
        @graph[source].each do |e|
          next_cost = dist[source] + e.weight
          if next_cost < dist[e.target]
            dist[e.target] = next_cost
            next_node.push(next_cost.to_u64, e.target)
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
      dist = [OO] * @size
      dist[start] = 0_i64
      next_node = RadixHeap64(Int32).new
      next_node.push(0_u64, start.to_i32)

      birth = [-1] * @size
      until next_node.empty?
        d, source = next_node.pop
        next if dist[source] < d
        @graph[source].each do |e|
          next_cost = dist[source] + e.weight
          if next_cost < dist[e.target]
            dist[e.target] = next_cost
            next_node.push(next_cost.to_u64, e.target)
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
      dist = [OO] * @size
      dist[start] = 0_i64
      prev = Array(Int32?).new(@size) { nil }
      next_node = RadixHeap64(Int32).new
      next_node.push(0_u64, start.to_i32)

      until next_node.empty?
        d, source = next_node.pop
        next if dist[source] < d
        @graph[source].each do |e|
          next_cost = dist[source] + e.weight
          if next_cost < dist[e.target]
            dist[e.target] = next_cost
            prev[e.target] = source
            next_node.push(next_cost.to_u64, e.target)
          end
        end
      end

      prev
    end
  end
end
