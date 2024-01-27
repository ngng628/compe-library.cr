module NgLib
  class TSPGraph(T)
    getter size : Int32
    getter mat : Array(Array(T?))

    def initialize(n : Int)
      @size = n.to_i32
      @mat = Array.new(n) { Array.new(n) { nil.as(T?) } }
      n.times do |i|
        @mat[i][i] = T.zero
      end
    end

    def add_edge(u : Int, v : Int, w : T, directed : Bool = false)
      @mat[u][v] = w
      @mat[v][u] = w unless directed
    end

    def shortest_route(start : Int = 0)
      dp = Array.new(1 << @size) { Array.new(@size) { nil.as(T?) } }
      dp[0][start] = T.zero
      (1 << @size).times do |visited|
        @size.times do |dest|
          @size.times do |from|
            next if visited != 0 && visited.bit(from) == 0
            next if visited.bit(dest) == 1
            next if from == dest
            now = dp[visited][from]
            d = @mat[from][dest]
            next if now.nil?
            next if d.nil?
            dist = now + d
            nxt = dp[visited | (1 << dest)][dest]
            if nxt.nil? || nxt > d
              dp[visited | (1 << dest)][dest] = dist
            end
          end
        end
      end
      dp
    end
  end
end
