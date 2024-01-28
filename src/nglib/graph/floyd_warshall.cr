module NgLib
  # ワーシャル・フロイド法の実装です。
  #
  # （負を含む）重み付きグラフに対して、
  # 全点対最短経路長が $O(V^3)$ で求まります。
  class FloydWarshallGraph(T)
    getter size : Int32
    getter mat : Array(Array(T?))

    # $n$ 頂点 $0$ 辺のグラフを作ります。
    #
    # ```
    # n = 10
    # NgLib::FloydWarshallGraph(Int64).new(n)
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
    # NgLib::FloydWarshallGraph(Int32).new(mat)
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
    # graph = NgLib::FloydWarshallGraph.new(n)
    # m.times do
    #   u, v, w = read_line.split.map &.to_i64
    #   u -= 1; v -= 1  # 0-index
    #   graph.add_edge(u, v, w, directed: true)
    # end
    # ```
    def add_edge(u : Int, v : Int, w : T, directed : Bool = false)
      @mat[u][v] = w
      @mat[v][u] = w unless directed
    end

    # 全点対最短経路長を返します。
    #
    # どのような経路を辿っても到達できない場合は `nil` が格納されます。
    #
    # ```
    # mat = [[0, 3, 1], [-2, 0, 4], [nil, nil, 0]]
    # graph = NgLib::FloydWarshallGraph.new(mat)
    # d = graph.shortest_path # => [[0, 3, 1], [-2, 0, -1], [nil, nil, 0]]
    # d[0][1] # => 3  (i から j への最短経路長)
    # ```
    def shortest_path
      dist = @mat.clone
      @size.times do |via|
        @size.times do |from|
          @size.times do |dest|
            d1 = dist[from][via]
            d2 = dist[via][dest]
            next if d1.nil?
            next if d2.nil?
            d = dist[from][dest]
            if d.nil? || d > d1 + d2
              dist[from][dest] = d1 + d2
            end
          end
        end
      end
      dist
    end
  end
end
