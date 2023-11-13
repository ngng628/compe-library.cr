module NgLib
  class SCC
    alias Graph = Array(Array(Int64))

    getter leader : Array(Int64)
    getter graph : Graph
    getter groups : Array(Array(Int64))
    @n : Int64
    @order : Array(Int64)
    @fwd : Graph
    @bwd : Graph
    @closed : Array(Bool)
    @cycles : Array(Array(Int64))

    def initialize(@fwd : Graph)
      @n = @fwd.size.to_i64
      @order = Array(Int64).new(@n)
      @leader = Array.new(@n, -1_i64)
      @bwd = Array.new(@n){ Array(Int64).new }
      @n.times do |i|
        @fwd[i].each do |j|
          @bwd[j] << i
        end
      end

      @closed = Array(Bool).new(@n, false)
      @n.times{ |i| dfs(i) }
      @order = @order.reverse
      ptr = rdfs

      @graph = Array.new(ptr){ Array(Int64).new }
      @groups = Array.new(ptr){ Array(Int64).new }
      @n.times do |i|
        @groups[@leader[i]] << i
        @fwd[i].each do |j|
          x, y = @leader[i], @leader[j]
          next if x == y
          @graph[x] << y
        end
      end

      @cycles = Array(Array(Int64)).new
    end

    def same(u : Int, v : Int)
      leader[u] == leader[v]
    end

    def size
      @groups.size
    end

    def size(v : Int)
      @groups[leader[v]].size
    end

    # 各グループ `g` $\in$ `#groups` に対して、
    # サイクルに現れる頂点をDFSの訪問順に並べたものを返します。
    #
    # NOTE: 自己ループがある場合、サイズ 1 のサイクルが出現することに注意してください。
    def cycles
      groups.each do |g|
        root = g[0]
        if g.size == 1
          cycles << [root.to_i64] if @fwd[root].includes?(root)
          next
        end
      end
    end

    private def dfs(i : Int)
      return if @closed[i]
      @closed[i] = true
      @fwd[i].each{ |j| dfs(j) }
      @order << i
    end

    private def rdfs
      ptr = 0_i64
      closed = Array.new(@n, false)
      @order.each do |s|
        next if closed[s]
        que = Deque(Int64).new
        que << s
        closed[s] = true
        @leader[s] = ptr
        until que.empty?
          now = que.shift
          @bwd[now].each do |nxt|
            next if closed[nxt]
            closed[nxt] = true
            @leader[nxt] = ptr
            que << nxt
          end
        end
        ptr += 1
      end
      ptr
    end
  end
end
