module NgLib
  # 不変な二次元配列 $A$ に対して、$\sum_{i=l_i}^{r_i-1} \sum_{j=l_j}^{r_j-1} A_i$ を前計算 $O(N)$ クエリ $O(1)$ で求めます。
  class StaticRectangleSum(T)
    getter height : Int32
    getter width : Int32
    getter csum : Array(Array(T))

    def initialize(grid : Array(Array(T)))
      @height = grid.size
      @width = (grid[0]? || [] of T).size
      @csum = Array.new(@height + 1) { Array.new(@width + 1) { T.zero } }
      @height.times do |i|
        @width.times do |j|
          @csum[i + 1][j + 1] = @csum[i][j + 1] + @csum[i + 1][j] - @csum[i][j] + grid[i][j]
        end
      end
    end

    # 累積和を返します。
    #
    # [y_begin, y_end), [x_begin, x_end) で指定します。
    #
    # NOTE: このAPIは非推奨です。Rangeで指定することが推奨されます。
    def get(y_begin : Int, y_end : Int, x_begin : Int, x_end : Int) : T
      raise IndexError.new("`y_begin` must be less than or equal to `y_end` (#{y_begin}, #{y_end})") unless y_begin <= y_end
      raise IndexError.new("`x_begin` must be less than or equal to `x_end` (#{x_begin}, #{x_end})") unless x_begin <= x_end
      @csum[y_end][x_end] - @csum[y_begin][x_end] - @csum[y_end][x_begin] + @csum[y_begin][x_begin]
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
      @csum[y_end][x_end] - @csum[y_begin][x_end] - @csum[y_end][x_begin] + @csum[y_begin][x_begin]
    end

    # 累積和を取得します。
    #
    # Range(y_begin, y_end), Range(x_begin, x_end) で指定します。
    #
    # ```
    # csum = StaticRectangleSum.new(a)
    # csum.get(0...h, j..j + 2) # => 28
    # ```
    def get(y_range : Range(Int?, Int?), x_range : Range(Int?, Int?)) : T
      y_begin = (y_range.begin || 0)
      y_end = (y_range.end || @height) + (y_range.exclusive? || y_range.end.nil? ? 0 : 1)
      x_begin = (x_range.begin || 0)
      x_end = (x_range.end || @height) + (x_range.exclusive? || x_range.end.nil? ? 0 : 1)
      get(y_begin, y_end, x_begin, x_end)
    end

    # 累積和を返します。
    #
    # [y_begin, y_end), [x_begin, x_end) で指定します。
    #
    # 範囲内に要素が存在しない場合 nil を返します。
    #
    # ```
    # csum = StaticRectangleSum.new(a)
    # csum.get?(0...h, j..j + 2)     # => 28
    # csum.get?(0...100*h, j..j + 2) # => nil
    # ```
    def get?(y_range : Range(Int?, Int?), x_range : Range(Int?, Int?)) : T?
      y_begin = (y_range.begin || 0)
      y_end = (y_range.end || @height) + (y_range.exclusive? || y_range.end.nil? ? 0 : 1)
      x_begin = (x_range.begin || 0)
      x_end = (x_range.end || @height) + (x_range.exclusive? || x_range.end.nil? ? 0 : 1)
      get?(y_begin, y_end, x_begin, x_end)
    end

    def [](y_range : Range(Int?, Int?), x_range : Range(Int?, Int?)) : T
      get(y_range, x_range)
    end

    def []?(y_range : Range(Int?, Int?), x_range : Range(Int?, Int?)) : T?
      get?(y_range, x_range)
    end
  end
end
