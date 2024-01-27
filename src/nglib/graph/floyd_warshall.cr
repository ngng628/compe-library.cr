module NgLib
  class FloydWarshallGraph(T)
    getter size : Int32
    getter mat : Array(Array(T?))

    def initialize(n : Int)
      @size = n.to_i32
      @mat = Array.new(n) { Array.new(n) { nil.as(T?) } }
      @size.times do |i|
        @mat[i][i] = T.zero
      end
    end

    def initialize(@mat : Array(Array(T?)))
      @size = @mat.size
      @size.times do |i|
        @mat[i][i] = T.zero
      end
    end

    def add_edge(u : Int, v : Int, w : T, directed : Bool = false)
      @mat[u][v] = w
      @mat[v][u] = w unless directed
    end

    def shortest_path : Array(Array(T?))
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
