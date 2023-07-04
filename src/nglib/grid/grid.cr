require "../constants.cr"
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

    def self.dydx4(s : Array(Array(T)))
      new(s, DYDX4)
    end

    def self.dydx8(s : Array(Array(T)))
      new(s, DYDX8)
    end

    def initialize(s : Array(Array(T)), @delta)
      @h = s.size
      @w = s[0].size
      @s = s.flatten
      @bar = T.bar
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

    # 全マス間の最短経路長を返します。
    #
    # ```
    # dist = grid.shortest_path
    # dist[si][sj][gi][gj] # => 4
    # ```
    def shortest_path : Array(Array(Int64))
      Array.new(@h) { |si|
        Array.new(@w) { |sj|
          shortest_path(si, sj)
        }
      }
    end

    # 始点 $(s_i, s_j)$ から各マスへの最短経路長を返します。
    #
    # ```
    # dist = grid.shortest_path(start: {si, sj})
    # dist[gi][gj] # => 4
    # ```
    def shortest_path(start : Tuple) : Array(Array(Int64))
      queue = Deque.new([start])
      dist = Array.new(@h) { Array.new(@w) { OO } }
      dist[start[0]][start[1]] = 0
      until queue.empty?
        i, j = queue.shift
        each_neighbor(i, j) do |ni, nj|
          next if dist[ni][nj] != OO
          dist[ni][nj] = dist[i][j] + 1
          queue << {ni, nj}
        end
      end
      dist
    end

    # 始点 $(s_i, s_j)$ から終点 $(g_i, g_j)$ への最短経路長を返します。
    #
    # ```
    # grid.shortest_path(start: {si, sj}, dest: {gi, gj}) # => 4
    # ```
    def shortest_path(start : Tuple, dest : Tuple) : Int64
      shortest_path(start)[dest[0]][dest[1]]
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
    # dist = grid.shortest_path { |i, j, ni, nj| f(i, j, ni, nj) }
    # dist[si][sj][gi][gj] # => 4
    # ```
    def shortest_path(tag = :dijkstra, & : Int32, Int32, Int32, Int32 -> U) : Array(Array(Int64)) forall U
      Array.new(@h) { |si|
        Array.new(@w) { |sj|
          shortest_path(si, sj) { |i, j, ni, nj| yield i, j, ni, nj }
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
    # dist = grid.shortest_path(start: {0, 0}) { |i, j, ni, nj| f(i, j, ni, nj) }
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
          each_neighbor(i, j) do |ni, nj|
            weight = yield i.to_i32, j.to_i32, ni.to_i32, nj.to_i32
            raise "Weight error" unless weight == U.zero.succ || weight == U::MAX
            next if weight == U::MAX
            next if dist[ni][nj] != U::MAX
            dist[ni][nj] = dist[i][j] + U.zero.succ
            next_node << {ni, nj}
          end
        end
        return dist
      when :binary_bfs
        next_node = Deque({Int32, Int32}).new([start])
        dist = Array.new(@h) { Array.new(@w) { U::MAX } }
        dist[start[0]][start[1]] = U.zero
        until next_node.empty?
          i, j = next_node.shift
          each_neighbor(i, j) do |ni, nj|
            weight = yield i.to_i32, j.to_i32, ni.to_i32, nj.to_i32
            raise "Weight error" unless weight.in?({U.zero, U.zero.succ})
            next_cost = dist[i][j] <= U::MAX - weight ? dist[i][j] + weight : U::MAX
            if next_cost < dist[ni][nj]
              dist[ni][nj] = next_cost
              if weight == 0
                next_node.unshift({ni.to_i32, nj.to_i32})
              else
                next_node << {ni.to_i32, nj.to_i32}
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
          each_neighbor(i, j) do |ni, nj|
            weight = yield i.to_i32, j.to_i32, ni.to_i32, nj.to_i32
            next_cost = dist[i][j] <= U::MAX - weight ? dist[i][j] + weight : U::MAX
            if next_cost < dist[ni][nj]
              dist[ni][nj] = next_cost
              next_node << {next_cost, {ni.to_i32, nj.to_i32}}
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
    # grid.shortest_path(start: {si, sj}, dest: {gi, gj}) { |i, j, ni, nj|
    #   f(i, j, ni, nj)
    # } # => 4
    # ```
    def shortest_path(start : Tuple, dest : Tuple, tag = :dijkstra, & : Int32, Int32, Int32, Int32 -> U) : Int64 forall U
      shortest_path(start, tag) { |i, j, ni, nj| yield i, j, ni, nj }[dest[0]][dest[1]]
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
            ni = i + di
            nj = j + dj
            next if over?(ni, nj)
            node2 = @w * ni + nj

            both_frees = free?(i, j) & free?(ni, nj)
            both_bars = barred?(i, j) & barred?(ni, nj)

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

    # TODO: よりよい命名を考える

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

    def index(& : T ->) : {Int32, Int32}?
      each_with_coord do |c, (i, j)|
        return {i, j} if yield c
      end
      nil
    end

    def index(obj) : {Int32, Int32}?
      index { |c| c == obj }
    end

    def index!(& : T ->) : {Int32, Int32}
      index { |c| yield c } || raise Exception.new("Not found.")
    end

    def index!(obj) : {Int32, Int32}?
      index! { |c| c == obj }
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
