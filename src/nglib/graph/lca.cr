require "../constants.cr"

module NgLib
  class LCA
    alias Graph = Array(Array(Int64))
    getter parent : Array(Array(Int64))
    getter dist : Array(Int64)
    @graph : Graph
  
    # 木構造グラフ `graph` に対して、`root` を根とする LCA を構築します。
    def initialize(@graph : Graph, root = 0_i64)
      n = graph.size
      k = 1_i64
      while (1_i64 << k) < n
        k += 1
      end
  
      @parent = Array.new(k){ [-1_i64] * n }
      @dist = [OO] * n
      dfs(root, -1_i64, 0_i64)
      (k - 1).times do |i|
        n.times do |v|
          if @parent[i][v] < 0
            @parent[i + 1][v] = -1_i64
          else
            @parent[i + 1][v] = @parent[i][@parent[i][v]]
          end
        end
      end
    end

    # 頂点 `u` と 頂点 `v` の最近共通祖先を返します。
    def ancestor(u : Int, v : Int) : Int64
      if @dist[u] < @dist[v]
        u, v = v, u
      end
      n = @parent.size
      n.times do |k|
        u = @parent[k][u] if (dist[u] - dist[v]).bit(k) == 1
      end
      return u if u == v
      (n - 1).downto(0) do |k|
        if @parent[k][u] != @parent[k][v]
          u, v = @parent[k][u], @parent[k][v]
        end
      end
      @parent[0][u]
    end
  
    # 頂点 `u` と頂点 `v` の距離を返します。
    def distanceBetween(u : Int, v : Int) : Int64
      dist[u] + dist[v] - dist[ancestor(u, v)] * 2
    end

    # 頂点 `u` から頂点 `v` までのパスに頂点 `a` が含まれているか返します。
    def on_path?(u : Int, v : Int, a : Int) : Bool
      distanceBetween(u, a) + distanceBetween(a, v) == distanceBetween(u, v)
    end
  
    private def dfs(root : Int64, par : Int64, d : Int64)
      @parent[0][root] = par
      @dist[root] = d
      @graph[root].each do |child|
        next if child == par
        dfs(child, root, d + 1)
      end
    end
  end
end
