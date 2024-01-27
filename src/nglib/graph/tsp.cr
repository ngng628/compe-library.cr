module NgLib
  class TSPGraph(T)
    getter size : Int32
    getter mat : Array(Array(T?))

    def initialize(n : Int)
      @size = n.to_i32
      @mat = Array.new(n) { Array.new(n) { nil.as(T?) } }
      @size.times do |i|
        @mat[i][i] = T.zero
      end
    end

    def add_edge(u : Int, v : Int, w : T, directed : Bool = false)
      @mat[u][v] = w
      @mat[v][u] = w unless directed
    end

    def shortest_route(should_back : Bool = true)
      dp = Array.new(1 << @size) { Array.new(@size) { nil.as(T?) } }

      if should_back
        dp[0][0] = T.zero
      else
        @size.times do |i|
          dp[1 << i][i] = T.zero
        end
      end

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
