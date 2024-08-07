require "atcoder/priority_queue"

struct Int
  def self.bar
    -1
  end
end

struct Char
  def self.bar
    '#'
  end
end

module NgLib
  class Grid(T)
    class UnreachableError < Exception
    end

    include Enumerable(T)

    def self.add(v1 : {Int, Int}, v2 : {Int, Int})
      {v1[0] + v2[0], v1[1] + v2[1]}
    end

    def self.sub(v1 : {Int, Int}, v2 : {Int, Int})
      {v1[0] - v2[0], v1[1] - v2[1]}
    end

    UP    = {-1, 0}
    LEFT  = {0, -1}
    DOWN  = {1, 0}
    RIGHT = {0, 1}
    DYDX2 = [DOWN, RIGHT]
    DYDX4 = [UP, LEFT, DOWN, RIGHT]

    DYDX8 = [
      UP,
      add(UP, RIGHT),
      RIGHT,
      add(DOWN, RIGHT),
      DOWN,
      add(DOWN, LEFT),
      LEFT,
      add(UP, LEFT),
    ]

    alias Pos = {Int32, Int32}
    getter h : Int32, w : Int32
    getter delta : Array(Pos)
    @s : Array(T)
    @bar : T

    def self.dydx2(s : Array(Array(T)))
      new(s, DYDX2)
    end

    def self.dydx2(height : Int, width : Int)
      new(height, width, DYDX2)
    end

    def self.dydx2(height : Int, &)
      new(height, DYDX2) { |line| yield line }
    end

    def self.dydx4(s : Array(Array(T)))
      new(s, DYDX4)
    end

    def self.dydx4(height : Int, width : Int, &)
      new(height, width, DYDX4) { |i, j| yield i, j }
    end

    def self.dydx4(height : Int, &)
      new(height, DYDX4) { |line| yield line }
    end

    def self.dydx8(s : Array(Array(T)))
      new(s, DYDX8)
    end

    def self.dydx8(height : Int, width : Int, &)
      new(height, width, DYDX8) { |i, j| yield i, j }
    end

    def self.dydx8(height : Int, &)
      new(height, DYDX8) { |line| yield line }
    end

    def initialize(s : Array(Array(T)), @delta)
      @h = s.size
      @w = s[0].size
      @s = s.flatten
      @bar = T.bar
    end

    def initialize(h : Int, @delta, &)
      @h = h.to_i
      @w = -1
      @s = Array(Array(T)).new(h) { |line| t = (yield line); @w = t.size; t }.flatten
      raise "@w is null" if @w == -1
      @bar = T.bar
    end

    def initialize(h : Int, w : Int, @delta, &)
      @h = h.to_i
      @w = w.to_i
      @s = Array(T).new(h * w) { |x| yield x // w, x % w }
      @bar = T.bar
    end

    # 位置 `pos` に対して次の座標をタプルで返します。
    #
    # ここで「次」とは、each_with_coord で走査するときの順と同様です。
    #
    # 次が存在しない場合は `nil` を返します。
    #
    # ```
    # grid.h, grid.w # => 3, 4
    # grid.next_coord({1, 2}) # => {1, 3}
    # grid.next_coord({1, 3}) # => {2, 0}
    # grid.next_coord({2, 3}) # => nil
    # ```
    def next_coord(pos)
      j = (pos[1] + 1) % @w
      i = pos[0] + (j == 0 ? 1 : 0)
      i >= @h ? nil : {i, j}
    end

    # 位置 `pos` に対して次の座標をタプルで返します。
    #
    # ここで「次」とは、each_with_coord で走査するときの順と同様です。
    #
    # 次が存在しない場合はエラーを送出します。
    #
    # ```
    # grid.h, grid.w # => 3, 4
    # grid.next_coord({1, 2}) # => {1, 3}
    # grid.next_coord({1, 3}) # => {2, 0}
    # grid.next_coord({2, 3}) # => nil
    # ```
    def next_coord!(pos)
      next_coord(pos) || raise Exception.new
    end

    # 位置 `pos` がグリッドの範囲外なら `true` を返します。
    #
    # ```
    # grid.over?({-1, 0})          # => true
    # grid.over?({h + 10, w + 10}) # => true
    # grid.over?({0, 0})           # => false
    # ```
    @[AlwaysInline]
    def over?(pos) : Bool
      over?(pos[0], pos[1])
    end

    # 位置 $(y, x)$ がグリッドの範囲外なら `true` を返します。
    #
    # ```
    # grid.over?(-1, 0)          # => true
    # grid.over?(h + 10, w + 10) # => true
    # grid.over?(0, 0)           # => false
    # ```
    @[AlwaysInline]
    def over?(y, x) : Bool
      y < 0 || y >= @h || x < 0 || x >= @w
    end

    # 位置 `pos` が進入禁止なら `true` を返します。
    #
    # ```
    # s = [
    #   "..".chars,
    #   ".#".chars,
    # ]
    #
    # grid.barred?({0, 0}) # => false
    # grid.barred?({1, 1}) # => true
    # ```
    @[AlwaysInline]
    def barred?(pos) : Bool
      barred?(pos[0], pos[1])
    end

    # 位置 $(y, x)$ が進入禁止なら `true` を返します。
    #
    # ```
    # s = [
    #   "..".chars,
    #   ".#".chars,
    # ]
    #
    # grid.barred?(0, 0) # => false
    # grid.barred?(1, 1) # => true
    # ```
    @[AlwaysInline]
    def barred?(y : Int, x : Int) : Bool
      over?(y, x) || self[y, x] == @bar
    end

    # 位置 `pos` が通行可能なら `true` を返します。
    #
    # ```
    # s = [
    #   "..".chars,
    #   ".#".chars,
    # ]
    #
    # grid.free?({0, 0}) # => true
    # grid.free?({1, 1}) # => false
    # ```
    @[AlwaysInline]
    def free?(pos) : Bool
      !barred?(pos)
    end

    # 位置 $(y, x)$ が通行可能なら `true` を返します。
    #
    # ```
    # s = [
    #   "..".chars,
    #   ".#".chars,
    # ]
    #
    # grid.free?(0, 0) # => true
    # grid.free?(1, 1) # => false
    # ```
    @[AlwaysInline]
    def free?(y : Int, x : Int) : Bool
      !barred?(y, x)
    end

    def simulate(si : Int, sj : Int, directions : Enumerable, iterations : Enumerable) : {Int32, Int32}
      lwalls = self.line_walls
      cwalls = self.column_walls

      now_i, now_j = si.to_i, sj.to_i
      directions.zip(iterations) do |dir, iter|
        case dir
        when 'L'
          walls = lwalls[now_i]
          pos = (walls.bsearch_index { |x| x >= now_j } || walls.size) - 1
          next_j = walls[pos] + 1
          now_j = {now_j - iter, next_j}.max
        when 'R'
          walls = lwalls[now_i]
          pos = walls.bsearch_index { |x| x > now_j }
          next_j = pos ? walls[pos] - 1 : @w - 1
          now_j = {now_j + iter, next_j}.min
        when 'U'
          walls = cwalls[now_j]
          pos = (walls.bsearch_index { |x| x >= now_i } || walls.size) - 1
          next_i = (pos >= 0 ? walls[pos] : -1) + 1
          now_i = {now_i - iter, next_i}.max
        when 'D'
          walls = cwalls[now_j]
          pos = walls.bsearch_index { |x| x > now_i }
          next_i = pos ? walls[pos] - 1 : @h - 1
          now_i = {now_i + iter, next_i}.min
        end
      end

      {now_i, now_j}
    end

    def simulate(si : Int, sj : Int, directions : Enumerable) : {Int32, Int32}
      simulate(si, sj, directions, [1] * directions.size)
    end

    def line_walls : Array(Array(Int32))
      walls = Array.new(@h) { [] of Int32 }
      @h.times do |i|
        walls[i] << -1
        @w.times do |j|
          walls[i] << j if barred?(i, j)
        end
        walls[i] << @w
      end
      walls
    end

    def column_walls : Array(Array(Int32))
      walls = Array.new(@w) { [] of Int32 }
      @w.times do |j|
        walls[j] << -1
        @h.times do |i|
          walls[j] << i if barred?(i, j)
        end
        walls[j] << @h
      end
      walls
    end

    # 全マス間の最短経路長を返します。
    #
    # 到達できない場合は `nil` が格納されます。
    #
    # ```
    # dist = grid.shortest_path
    # dist[si][sj][gi][gj] # => 4
    # ```
    def shortest_path : Array(Array(Array(Array(Int64?))))
      Array.new(@h) { |start_i|
        Array.new(@w) { |start_j|
          shortest_path(start_i, start_j)
        }
      }
    end

    # 始点 $(s_i, s_j)$ から各マスへの最短経路長を返します。
    #
    # 到達できない場合は `nil` が格納されます。
    #
    # ```
    # dist = grid.shortest_path(start: {si, sj})
    # dist[gi][gj] # => 4
    # ```
    def shortest_path(start : Tuple) : Array(Array(Int64?))
      queue = Deque.new([start])
      dist = Array.new(@h) { Array.new(@w) { nil.as(Int64?) } }
      dist[start[0]][start[1]] = 0
      until queue.empty?
        i, j = queue.shift
        d = dist[i][j] || raise NilAssertionError.new
        each_neighbor(i, j) do |i_adj, j_adj|
          next unless dist[i_adj][j_adj].nil?
          dist[i_adj][j_adj] = d + 1
          queue << {i_adj, j_adj}
        end
      end
      dist
    end

    # :ditto:
    def shortest_path(start_i : Int, start_j : Int) : Array(Array(Int64?))
      shortest_path({start_i, start_j})
    end

    # 始点 $(s_i, s_j)$ から終点 $(g_i, g_j)$ への最短経路長を返します。
    #
    # ```
    # grid.shortest_path(start: {si, sj}, dest: {gi, gj}) # => 4
    # ```
    def shortest_path(start : Tuple, dest : Tuple) : Int64?
      shortest_path(start)[dest[0]][dest[1]]
    end

    # 始点 $(s_i, s_j)$ から終点 $(g_i, g_j)$ への最短経路長を返します。
    #
    # ```
    # grid.shortest_path(start: {si, sj}, dest: {gi, gj}) # => 4
    # ```
    def shortest_path!(start : Tuple, dest : Tuple) : Int64
      shortest_path(start)[dest[0]][dest[1]] || raise UnreachableError.new
    end

    # 全マス間の最短経路長を返します。
    #
    # 内部で利用するアルゴリズムをタグで指定します。
    # - `:bfs` : 侵入不可能な場合は U::MAX を返してください。
    # - `:binary_bfs` : 重みは $0$ または $1$ である必要があります。
    # - `:dijkstra` : デフォルト値です。$\infty = U::MAX$ です。負の数には気をつけてください。
    #
    # $(i, j)$ から $(i', j')$ への移動時の重みをブロックで指定します。
    #
    # ```
    # dist = grid.shortest_path { |i, j, i_adj, j_adj| f(i, j, i_adj, j_adj) }
    # dist[si][sj][gi][gj] # => 4
    # ```
    def shortest_path(tag = :dijkstra, & : Int32, Int32, Int32, Int32 -> U) : Array(Array(Int64)) forall U
      Array.new(@h) { |start_i|
        Array.new(@w) { |start_j|
          shortest_path(start_i, start_j) { |i, j, i_adj, j_adj| yield i, j, i_adj, j_adj }
        }
      }
    end

    # 始点 $(s_i, s_j)$ から各マスへの最短経路長を返します。
    #
    # 内部で利用するアルゴリズムをタグで指定します。
    # - `:bfs` : 侵入不可能な場合は U::MAX を返してください。
    # - `:binary_bfs` : 重みは $0$ または $1$ である必要があります。
    # - `:dijkstra` : デフォルト値です。$\infty = U::MAX$ です。負の数には気をつけてください。
    #
    # $(i, j)$ から $(i', j')$ への移動時の重みをブロックで指定します。
    #
    # ```
    # dist = grid.shortest_path(start: {0, 0}) { |i, j, i_adj, j_adj| f(i, j, i_adj, j_adj) }
    # dist[gi][gj] # => 4
    # ```
    # ameba:disable Metrics/CyclomaticComplexity
    def shortest_path(start : Tuple, tag = :dijkstra, & : Int32, Int32, Int32, Int32 -> U) : Array(Array(U)) forall U
      case tag
      when :bfs
        next_node = Deque({Int32, Int32}).new([start])
        dist = Array.new(@h) { Array.new(@w) { U::MAX } }
        dist[start[0]][start[1]] = U.zero
        until next_node.empty?
          i, j = next_node.shift
          each_neighbor(i, j) do |i_adj, j_adj|
            weight = yield i.to_i32, j.to_i32, i_adj.to_i32, j_adj.to_i32
            raise "Weight error" unless weight == U.zero.succ || weight == U::MAX
            next if weight == U::MAX
            next if dist[i_adj][j_adj] != U::MAX
            dist[i_adj][j_adj] = dist[i][j] + U.zero.succ
            next_node << {i_adj, j_adj}
          end
        end
        return dist
      when :binary_bfs
        next_node = Deque({Int32, Int32}).new([start])
        dist = Array.new(@h) { Array.new(@w) { U::MAX } }
        dist[start[0]][start[1]] = U.zero
        until next_node.empty?
          i, j = next_node.shift
          each_neighbor(i, j) do |i_adj, j_adj|
            weight = yield i.to_i32, j.to_i32, i_adj.to_i32, j_adj.to_i32
            raise "Weight error" unless weight.in?({U.zero, U.zero.succ})
            next_cost = dist[i][j] <= U::MAX - weight ? dist[i][j] + weight : U::MAX
            if next_cost < dist[i_adj][j_adj]
              dist[i_adj][j_adj] = next_cost
              if weight == 0
                next_node.unshift({i_adj.to_i32, j_adj.to_i32})
              else
                next_node << {i_adj.to_i32, j_adj.to_i32}
              end
            end
          end
        end
        return dist
      when :dijkstra
        next_node = AtCoder::PriorityQueue.new([{U.zero, start}])
        dist = Array.new(@h) { Array.new(@w) { U::MAX } }
        dist[start[0]][start[1]] = U.zero
        until next_node.empty?
          d, pos = next_node.pop.not_nil!
          i, j = pos
          next if dist[i][j] < d
          each_neighbor(i, j) do |i_adj, j_adj|
            weight = yield i.to_i32, j.to_i32, i_adj.to_i32, j_adj.to_i32
            next_cost = dist[i][j] <= U::MAX - weight ? dist[i][j] + weight : U::MAX
            if next_cost < dist[i_adj][j_adj]
              dist[i_adj][j_adj] = next_cost
              next_node << {next_cost, {i_adj.to_i32, j_adj.to_i32}}
            end
          end
        end
        return dist
      end
      raise "Tag Error"
    end

    # 始点 $(s_i, s_j)$ から終点 $(g_i, g_j)$ への最短経路長を返します。
    #
    # 内部で利用するアルゴリズムをタグで指定します。
    # - `:bfs` : 侵入不可能な場合は U::MAX を返してください。
    # - `:binary_bfs` : 重みは $0$ または $1$ である必要があります。
    # - `:dijkstra` : デフォルト値です。$\infty = U::MAX$ です。負の数には気をつけてください。
    #
    # $(i, j)$ から $(i', j')$ への移動時の重みをブロックで指定します。
    #
    # ```
    # grid.shortest_path(start: {si, sj}, dest: {gi, gj}) { |i, j, i_adj, j_adj|
    #   f(i, j, i_adj, j_adj)
    # } # => 4
    # ```
    def shortest_path(start : Tuple, dest : Tuple, tag = :dijkstra, & : Int32, Int32, Int32, Int32 -> U) : Int64 forall U
      shortest_path(start, tag) { |i, j, i_adj, j_adj| yield i, j, i_adj, j_adj }[dest[0]][dest[1]]
    end

    # グリッドを隣接リスト形式で無向グラフに変換します。
    #
    # あるマス $(i, j)$ の頂点番号は $Wi + j$ となります。
    #
    # - `:connect_free` : free 同士を結びます（デフォルト）
    # - `:connect_bar` : bar 同士を結びます
    # - `:connect_same_type` : bar 同士、free 同士を結びます
    #
    # ```
    # s = [
    #   "..#".chars,
    #   ".#.".chars,
    #   "##.".chars,
    # ]
    # grid = Grid(Char).dydx4(s)
    # grid.to_graph # => [[3, 1], [0], [], [0], [], [8], [], [], [5]]
    # ```
    def to_graph(type = :connect_free) : Array(Array(Int32))
      graph = Array.new(@w * @h) { [] of Int32 }

      @h.times do |i|
        @w.times do |j|
          node = @w * i + j
          @delta.each do |(di, dj)|
            i_adj = i + di
            j_adj = j + dj
            next if over?(i_adj, j_adj)
            node2 = @w * i_adj + j_adj

            both_frees = free?(i, j) & free?(i_adj, j_adj)
            both_bars = barred?(i, j) & barred?(i_adj, j_adj)

            case type
            when :connect_free
              graph[node] << node2 if both_frees
            when :connect_bar
              graph[node] << node2 if both_bars
            when :connect_same_type
              graph[node] << node2 if both_frees || both_bars
            end
          end
        end
      end
      graph
    end

    # 連結する free および bar を塗り分けたグリッドを返します。
    # free のマスは非負整数の連番でラベル付けされ、bar は負の連番でラベル付けされます。
    # `label_grid.max` は `(島の数 - 1)` を返すことに注意してください。
    #
    # ```
    # s = [
    #   "..#".chars,
    #   ".#.".chars,
    #   "##.".chars,
    # ]
    # grid = Grid(Char).dydx4(s)
    # grid.label_grid # => [[0, 0, -1], [0, -2, 1], [-2, -2, 1]]
    # ```
    def label_grid
      table = Array.new(@h) { [nil.as(Int32?)] * @w }

      free_index, bar_index = 0, -1
      @h.times do |i|
        @w.times do |j|
          next unless table[i][j].nil?

          label = 0
          is_bar = barred?(i, j)
          if is_bar
            label = bar_index
            bar_index -= 1
          else
            label = free_index
            free_index += 1
          end

          queue = Deque({Int32, Int32}).new([{i, j}])
          table[i][j] = label
          until queue.empty?
            y, x = queue.shift
            @delta.each do |(dy, dx)|
              ny = y + dy
              nx = x + dx
              next if over?(ny, nx)
              next unless table[ny][nx].nil?
              next if is_bar ^ barred?(ny, nx)
              table[ny][nx] = label
              queue << {ny, nx}
            end
          end
        end
      end

      Grid(Int32).new(table.map { |line| line.map(&.not_nil!) }, @delta)
    end

    # グリッドの値を $(0, 0)$ から $(H, W)$ まで順に列挙します。
    #
    # ```
    # s = [
    #   "..#".chars,
    #   ".#.".chars,
    #   "##.".chars,
    # ]
    # grid = Grid(Char).dydx4(s)
    # gird.each { |c| puts c } # => '.', '.', '#', '.', ..., '.'
    # ```
    def each(& : T ->)
      i = 0
      while i < h
        j = 0
        while j < w
          yield self[i, j]
          j += 1
        end
        i += 1
      end
    end

    # グリッドの値を $(0, 0)$ から $(H, W)$ まで順に列挙します。
    #
    # index は $Wi + j$ を返します。通常は `each_with_coord` を利用することを推奨します。
    def each_with_index(&)
      i = 0
      while i < h
        j = 0
        while j < w
          yield self[i, j], w*i + j
          j += 1
        end
        i += 1
      end
    end

    # グリッドの値を $(0, 0)$ から $(H, W)$ まで順に座標付きで列挙します。
    #
    # ```
    # s = [
    #   "..#".chars,
    #   ".#.".chars,
    #   "##.".chars,
    # ]
    # grid = Grid(Char).new(s)
    # gird.each { |c, (i, j)| puts c, {i, j} }
    # ```
    def each_with_coord(&)
      i = 0
      while i < h
        j = 0
        while j < w
          yield self[i, j], {i, j}
          j += 1
        end
        i += 1
      end
    end

    # グリッドの各要素に対して、ブロックを実行した結果に変換したグリッドを返します。
    def map(& : T -> U) : Grid(U) forall U
      ret = Array.new(h) { Array(U).new(w) }
      i = 0
      while i < h
        j = 0
        line = Array(U).new(w)
        while j < w
          line << yield self[i, j]
          j += 1
        end
        ret[i] = line
        i += 1
      end
      Grid(U).new(ret, @delta)
    end

    # グリッドの各要素に対して、ブロックを実行した結果に変換したグリッドを返します。
    def map_with_coord(& : T, {Int32, Int32} -> U) : Grid(U) forall U
      ret = Array.new(h) { Array(U).new(w) }
      i = 0
      while i < h
        j = 0
        line = Array(U).new(w)
        while j < w
          line << yield self[i, j], {i, j}
        end
        ret[i] = line
      end
      Grid(U).new(ret, @delta)
    end

    def index(offset = {0, 0}, & : T ->) : {Int32, Int32}?
      i, j = offset
      while i < @h
        while j < @w
          return {i, j} if yield self[i, j]
          j += 1
        end
        j = 0
        i += 1
      end
      nil
    end

    def index(obj, offset = {0, 0}) : {Int32, Int32}?
      index(offset) { |elem| elem == obj }
    end

    def index!(offset = {0, 0}, & : T ->) : {Int32, Int32}
      index(offset) { |elem| yield elem } || raise Exception.new("Not found.")
    end

    def index!(obj, offset = {0, 0}) : {Int32, Int32}?
      index!(offset) { |elem| elem == obj }
    end

    # 位置 $(y, x)$ の近傍で、侵入可能な位置を列挙します。
    #
    # ```
    # grid = Grid.dydx([".#.", "...", "..."])
    #
    # grid.each_neighbor(1, 1) do |ny, nx|
    # end
    # ```
    def each_neighbor(y : Int, x : Int, &)
      i = 0
      while i < @delta.size
        ny = y + @delta[i][0]
        nx = x + @delta[i][1]
        yield ny, nx if free?(ny, nx)
        i += 1
      end
    end

    # 位置 $(y, x)$ の近傍で、侵入可能な位置を方向とともに列挙します。
    #
    # ```
    # grid = Grid.dydx4([".#.", "...", "..."])
    #
    # grid.each_neighbor(1, 1) do |ny, nx, dir|
    # end
    # ```
    def each_neighbor_with_direction(y : Int, x : Int, &)
      i = 0
      while i < @delta.size
        ny = y + @delta[i][0]
        nx = x + @delta[i][1]
        yield ny, nx, i if free?(ny, nx)
        i += 1
      end
    end

    def node_index(y : Int, x : Int)
      y * @w + x
    end

    def fetch(y : Int, x : Int, default : T)
      over?(y, x) ? default : self[y, x]
    end

    def to_a : Array(Array(T))
      a = Array.new(@h) { Array(T).new(@w) }
      @h.times do |i|
        @w.times do |j|
          a[i] << self[i, j]
        end
      end
      a
    end

    def to_s(io : IO)
      @h.times do |i|
        @w.times do |j|
          io << ' ' if j != 0
          io << self[i, j]
        end
        io << '\n'
      end
      io
    end

    def [](pos : {Int, Int})
      self[pos[0], pos[1]]
    end

    def [](y : Int, x : Int)
      @s[y*@w + x]
    end

    def []=(pos : {Int, Int}, c : T)
      self[pos[0], pos[1]] = c
    end

    def []=(y : Int, x : Int, c : T)
      @s[y*@w + x] = c
    end
  end
end
