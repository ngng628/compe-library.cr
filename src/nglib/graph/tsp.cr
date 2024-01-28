module NgLib
  # 巡回セールスマン問題を解きます。
  #
  # 内部では BitDP を用いているため、
  # 頂点数が大きいグラフには対応できません。
  #
  # 通常の巡回セールスマン問題を解きたい場合は、
  # `#shortest_route(should_back : Bool = true)` を利用してください。
  #
  # 始点を指定したいという特殊な場合は、
  # `#shortest_route(start : Int, should_back : Bool = true)` を利用してください。
  #
  # オリジナルの巡回セールスマン問題は各頂点に一度しか訪れることができません。
  # 同じ頂点に複数回訪れられる場合は、`NgLib::FloydWarshall` などで、全点対最短経路長を求め、
  # それを隣接行列として渡してください。
  #
  # 計算量は $O(N^2 2^N)$ です。
  class TSPGraph(T)
    getter size : Int32
    getter mat : Array(Array(T?))

    # $n$ 頂点 $0$ 辺のグラフを作ります。
    #
    # ```
    # n = 10
    # NgLib::TSPGraph(Int64).new(n)
    # ```
    def initialize(n : Int)
      @size = n.to_i32
      @mat = Array.new(n) { Array.new(n) { nil.as(T?) } }
      @size.times do |i|
        @mat[i][i] = T.zero
      end
    end

    # 隣接行列に従ってグラフを作ります。
    #
    # `nil` は辺が存在しないことを表します。
    # 無限大の重みを持つ辺と捉えても良いです。
    #
    # ```
    # mat = [[0, 3, 1], [-2, 0, 4], [nil, nil, 0]]
    # NgLib::TSPGraph(Int32).new(mat)
    # ```
    def initialize(@mat : Array(Array(T?)))
      @size = @mat.size
      @size.times do |i|
        @mat[i][i] = T.zero
      end
    end

    # :ditto:
    def initialize(matrix : Array(Array(T?) | Array(T)))
      @mat = matrix.map { |line| line.map { |v| v.as(T?) } }
      @size = @mat.size
      @size.times do |i|
        @mat[i][i] = T.zero
      end
    end

    # 重みが $w$ の辺 $(u, v)$ を追加します。
    #
    # `directed` が `true` である場合、有向辺として追加します。
    #
    # ```
    # n, m = read_line.split.map &.to_i
    # graph = NgLib::TSPGraph.new(n)
    # m.times do
    #   u, v, w = read_line.split.map &.to_i64
    #   u -= 1; v -= 1 # 0-index
    #   graph.add_edge(u, v, w, directed: true)
    # end
    # ```
    def add_edge(u : Int, v : Int, w : T, directed : Bool = false)
      uv = @mat[u][v]
      if uv.nil?
        @mat[u][v] = w
      else
        @mat[u][v] = {uv, w}.min
      end

      unless directed
        vu = @mat[v][u]
        if vu.nil?
          @mat[v][u] = w
        else
          @mat[v][u] = {vu, w}.min
        end
      end
    end

    # `dp[S][i] := 今まで訪問した頂点の集合が S で、最後に訪れた頂点が i であるときの最小経路長` を
    # 返します。
    #
    # `should_back` が `true` なら、始点の頂点に戻ってこない場合の最小経路長を計算します。
    # また、任意の始点に対しての答えを求める点に注意してください。
    #
    # `should_back` が `false` なら通常の巡回セールスマン問題の答えです。
    # 始点が頂点 $0$ であることに注意してください。
    # つまり、`dp[(1 << n) - 1][0]` が答えです。
    #
    # どのような順でも到達できない場合は `nil` が格納されます。
    #
    # ```
    # graph = TSPGraph(Int64).new(n)
    # dist = graph.shortest_route
    # dist[(1 << n) - 1][0] # => ans
    # dist.last.first       # => ans
    # ```
    def shortest_route(should_back : Bool = true)
      dp = Array.new(1 << @size) { Array.new(@size) { nil.as(T?) } }

      if should_back
        dp[0][0] = T.zero
      else
        @size.times do |i|
          dp[1 << i][i] = T.zero
        end
      end

      calc(dp)
    end

    # `dp[S][i] := 今まで訪問した頂点の集合が S で、最後に訪れた頂点が i であるときの最小経路長` を
    # 返します。
    #
    # `should_back` が `true` なら、始点の頂点に戻ってこない場合の最小経路長を計算します。
    # また、始点が `start` であることに注意してください。
    #
    # `should_back` が `false` なら通常の巡回セールスマン問題の答えです。
    # 始点が頂点 `start` であることに注意してください。
    # つまり、`dp[(1 << n) - 1][start]` が答えです。
    #
    # どのような順でも到達できない場合は `nil` が格納されます。
    #
    # ```
    # graph = TSPGraph(Int64).new(n)
    # dist = graph.shortest_route(start: 2)
    # dist[(1 << n) - 1][2]
    # ```
    def shortest_route(start : Int, should_back : Bool = true)
      dp = Array.new(1 << @size) { Array.new(@size) { nil.as(T?) } }

      if should_back
        dp[0][start] = T.zero
      else
        dp[1 << start][start] = T.zero
      end

      calc(dp)
    end

    private def calc(dp : Array(Array(T?)))
      dist = @mat

      (1 << @size).times do |visited|
        @size.times do |dest|
          @size.times do |from|
            next if visited != 0 && visited.bit(from) == 0
            next if visited.bit(dest) == 1
            now = dp[visited][from]
            d = dist[from][dest]
            next if now.nil?
            next if d.nil?
            nxt = dp[visited | (1 << dest)][dest]
            if nxt.nil? || nxt > now + d
              dp[visited | (1 << dest)][dest] = now + d
            end
          end
        end
      end

      dp
    end
  end
end
