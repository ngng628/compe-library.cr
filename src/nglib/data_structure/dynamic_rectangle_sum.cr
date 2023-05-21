module NgLib
  class DynamicRectangleSum(T)
    getter height : Int32
    getter width : Int32
    getter csum : Array(Array(T))

    def initialize(h : Int, w : Int)
      @height = h.to_i32
      @width = w.to_i32
      @csum = Array.new(h + 1) { Array.new(w + 1, T.zero) }
    end

    def initialize(grid : Array(Array(T)))
      @height = grid.size
      @width = (grid[0]? || [] of T).size
      @csum = Array.new(@height + 1) { Array.new(@width + 1) { T.zero } }
      @height.times do |i|
        @width.times do |j|
          add(i, j, grid[i][j])
        end
      end
    end

    # (y, x) の要素に val を足します。
    #
    # 添字は 0-index です。
    #
    # ```
    # csum = DynamicRectangleSum.new(a)
    # csum.add(y, x, val) # => val
    # ```
    def add(y : Int, x : Int, val : T) : T
      raise IndexError.new("y = #{y} が配列外参照しています。 (@height = #{@height}") if y < 0 || y >= @height
      raise IndexError.new("x = #{x} が配列外参照しています。 (@height = #{@width}") if x < 0 || x >= @width
      i = y + 1
      while i <= @height
        j = x + 1
        while j <= @width
          @csum[i][j] += val
          j += (j & -j)
        end
        i += (i & -i)
      end
      val
    end

    # (y, x) の要素に val を足します。
    #
    # 添字は 0-index です。
    #
    # 加算に成功した場合 `true` を返します。
    #
    # ```
    # csum = DynamicRectangleSum.new(a)
    # csum.add?(y, x, x) # => true
    # ```
    def add?(y : Int, x : Int, val : T) : Bool
      return false if y < 0 || y >= @height
      return false if x < 0 || x >= @width
      i = y + 1
      while i <= @height
        j = x + 1
        while j <= @width
          @csum[i][j] += val
          j += (j & -j)
        end
        i += (i & -i)
      end
      true
    end

    # 累積和を返します。
    #
    # [y_begin, y_end), [x_begin, x_end) で指定します。
    #
    # NOTE: このAPIは非推奨です。Rangeで指定することが推奨されます。
    def get(y_begin : Int, y_end : Int, x_begin : Int, x_end : Int) : T
      raise IndexError.new("`y_begin` must be less than or equal to `y_end` (#{y_begin}, #{y_end})") unless y_begin <= y_end
      raise IndexError.new("`x_begin` must be less than or equal to `x_end` (#{x_begin}, #{x_end})") unless x_begin <= x_end
      query(y_end, x_end) - query(y_end, x_begin) - query(y_begin, x_end) + query(y_begin, x_begin)
    end

    # 累積和を返します。
    #
    # [y_begin, y_end), [x_begin, x_end) で指定します。
    #
    # 範囲内に要素が存在しない場合 nil を返します。
    #
    # NOTE: このAPIは非推奨です。Rangeで指定することが推奨されます。
    def get?(y_begin : Int, y_end : Int, x_begin : Int, x_end : Int) : T?
      return nil unless y_begin <= y_end
      return nil unless x_begin <= x_end
      query(y_end, x_end) - query(y_end, x_begin) - query(y_begin, x_end) + query(y_begin, x_end)
    end

    # 累積和を取得します。
    #
    # Range(y_begin, y_end), Range(x_begin, x_end) で指定します。
    #
    # ```
    # csum = DynamicRectangleSum.new(a)
    # csum.get(0...h, j..j + 2) # => 28
    # ```
    def get(y_range : Range(Int?, Int?), x_range : Range(Int?, Int?)) : T
      y_begin = (y_range.begin || 0)
      y_end = if y_range.end.nil?
                @height
              else
                y_range.end.not_nil! + (y_range.exclusive? ? 0 : 1)
              end
      x_begin = (x_range.begin || 0)
      x_end = if x_range.end.nil?
                @width
              else
                x_range.end.not_nil! + (x_range.exclusive? ? 0 : 1)
              end
      get(y_begin, y_end, x_begin, x_end)
    end

    # 累積和を返します。
    #
    # [y_begin, y_end), [x_begin, x_end) で指定します。
    #
    # 範囲内に要素が存在しない場合 nil を返します。
    #
    # ```
    # csum = DynamicRectangleSum.new(a)
    # csum.get?(0...h, j..j + 2)     # => 28
    # csum.get?(0...100*h, j..j + 2) # => nil
    # ```
    def get?(y_range : Range(Int?, Int?), x_range : Range(Int?, Int?)) : T?
      y_begin = (y_range.begin || 0)
      y_end = if y_range.end.nil?
                @height
              else
                y_range.end.not_nil! + (y_range.exclusive? ? 0 : 1)
              end
      x_begin = (x_range.begin || 0)
      x_end = if x_range.end.nil?
                @width
              else
                x_range.end.not_nil! + (x_range.exclusive? ? 0 : 1)
              end
      get?(y_begin, y_end, x_begin, x_end)
    end

    def [](y_range : Range(Int?, Int?), x_range : Range(Int?, Int?)) : T
      get(y_range, x_range)
    end

    def []?(y_range : Range(Int?, Int?), x_range : Range(Int?, Int?)) : T?
      get?(y_range, x_range)
    end

    def []=(i : Int, j : Int, val : T)
      add(i, j, val - get(i..i, j..j))
    end

    private def query(h : Int, w : Int) : T
      acc = T.zero
      i = h
      while i > 0
        j = w
        while j > 0
          acc += @csum[i][j]
          j -= (j & -j)
        end
        i -= (i & -i)
      end
      acc
    end
  end
end
