module NgLib
  class MaxFlowGraph(Cap)
    class Edge(T)
      getter to : Int32
      getter rev : Int32
      property cap : T

      def initialize(@to, @rev, @cap)
      end
    end

    getter size : Int32
    @graph : Array(Array(Edge(Cap)))
    @pos : Array({Int32, Int32})

    # 0 頂点 0 辺のグラフを作ります。
    #
    # ```
    # graph = MaxFlowGraph(Int64).new
    # ```
    def initialize
      @size = 0
      @graph = [] of Array(Edge(Cap))
      @pos = [] of {Int32, Int32}
    end

    # n 頂点 0 辺のグラフを作ります。
    #
    # ```
    # n = 10
    # graph = MaxFlowGraph(Int64).new(n)
    # ```
    def initialize(n : Int)
      @size = n.to_i32
      @graph = Array.new(n) { Array(Edge(Cap)).new }
      @pos = [] of {Int32, Int32}
    end

    # 頂点 from から頂点 to へ最大容量 cap、流量 0 の辺を追加します。
    #
    # 何番目に追加された辺であるかを返します。
    #
    # ```
    # n = 10
    # graph = MaxFlowGraph(Int64).new(n)
    # graph.add_edge(0, 1, 1) # => 0
    # graph.add_edge(1, 3, 2) # => 1
    # graph.add_edge(5, 6, 8) # => 2
    # ```
    def add_edge(from : Int, to : Int, cap : Cap) : Int32
      m = @pos.size
      @pos << {from.to_i32, @graph[from].size}
      from_id = @graph[from].size
      to_id = @graph[to].size
      to_id += 1 if from == to
      @graph[from] << Edge(Cap).new(to.to_i32, to_id, cap)
      @graph[to] << Edge(Cap).new(from.to_i32, from_id, Cap.zero)
      m
    end

    # 今の内部の辺の状態を返します。
    #
    # 辺の順番は add_edge での追加順と同じです。
    def get_edge(i : Int)
      e = @graph[@pos[i][0]][@pos[i][1]]
      re = @graph[e.to][e.rev]
      {from: @pos[i][0], to: e.to, cap: e.cap + re.cap, flow: re.cap}
    end

    # 今の内部の辺の状態を返します。
    #
    # 辺の順番は add_edge での追加順と同じです。
    def edges
      Array.new(@pos.size) { |i| get_edge(i) }
    end

    # i 番目に変更された辺の容量、流量をそれぞれ new_cap, new_flow に変更します。
    #
    # 他の辺の容量、流量は変更しません。
    def change_edge(i : Int, new_cap : Cap, new_flow : Cap)
      @graph[@pos[i].first][@pos[i].second].cap = new_cap - new_flow
      @graph[_e.to][_e.rev].cap = new_flow
    end

    # 頂点 s から頂点 t へ流せるだけ流し、流せた量を返します。
    #
    # 複数回呼ぶことも可能ですが、同じ結果を返すわけではありません。
    # 挙動については以下を参考にしてください。
    # - https://atcoder.github.io/ac-library/document_ja/appendix.html
    #
    # ```
    # n = 4
    # graph = MaxFlowGraph(Int64).new(n)
    # graph.add_edge(0, 1, 10) # => 0
    # graph.add_edge(1, 2, 2)  # => 1
    # graph.add_edge(0, 2, 5)  # => 2
    # graph.add_edge(1, 3, 6)  # => 3
    # graph.add_edge(2, 3, 3)  # => 4
    #
    # graph.flow(0, 3) # => 9
    # ```
    def flow(s : Int, t : Int)
      flow(s, t, Cap::MAX)
    end

    # 頂点 s から頂点 t へ流せるだけ流し、流せた量を返します。
    #
    # 複数回呼ぶことも可能ですが、同じ結果を返すわけではありません。
    # 挙動については以下を参考にしてください。
    # - https://atcoder.github.io/ac-library/document_ja/appendix.html
    #
    # ```
    # n = 4
    # graph = MaxFlowGraph(Int64).new(n)
    # graph.add_edge(0, 1, 10) # => 0
    # graph.add_edge(1, 2, 2)  # => 1
    # graph.add_edge(0, 2, 5)  # => 2
    # graph.add_edge(1, 3, 6)  # => 3
    # graph.add_edge(2, 3, 3)  # => 4
    #
    # graph.flow(0, 3, 6)   # => 6
    # graph.flow(0, 3, 100) # => 9  (本来の挙動であれば 3 を返します。)
    # ```
    # ameba:disable Metrics/CyclomaticComplexity
    def flow(s : Int, t : Int, flow_limit : Cap)
      level = [0] * @size
      iter = [0] * @size

      bfs = ->{
        level = [-1] * @size
        level[s] = 0
        que = Deque(Int32).new([s.to_i32])
        until que.empty?
          v = que.shift
          @graph[v].each do |e|
            next if e.cap == 0 || level[e.to] >= 0
            level[e.to] = level[v] + 1
            next if e.to == t
            que << e.to
          end
        end
      }

      dfs = uninitialized Int32, Cap -> Cap
      dfs = ->(v : Int32, up : Cap) {
        return up if v == s
        res = Cap.zero
        level_v = level[v]
        (iter[v]...@graph[v].size).each do |i|
          e = @graph[v][i]
          next if level_v <= level[e.to] || @graph[e.to][e.rev].cap == 0
          d = dfs.call(e.to, Math.min(up - res, @graph[e.to][e.rev].cap))
          next if d <= 0
          @graph[v][i].cap += d
          @graph[e.to][e.rev].cap -= d
          res += d
          return res if res == up
        end
        level[v] = @size
        res
      }

      res = Cap.zero
      while res < flow_limit
        bfs.call
        break if level[t] == -1
        iter = [0] * @size
        f = dfs.call(t.to_i32, flow_limit - res)
        break if f == 0
        res += f
      end

      res
    end

    # 長さ n の配列を返します。
    # i 番目の要素には、頂点 s から i へ残余グラフで到達可能なとき、またその時のみ true を返します。
    #
    # flow(s, t) を flow_limit なしでちょうど一回呼んだ後に呼ぶと、
    # 返り値は s, t 間の mincut に対応します。
    def min_cut(s : Int)
      closed = [false] * @size
      que = Deque(Int32).new([s.to_i32])
      unless que.empty?
        now = que.shift
        closed[now] = true
        @graph[now].each do |e|
          if e.cap != 0 && !closed[e.to]
            closed[e.to] = true
            que << e.to
          end
        end
      end
      closed
    end
  end
end
