module NgLib
  class StaticRectangleSum(T)
    getter height : Int32
    getter width : Int32
    getter csum : Array(Array(T))
  
    def initialize(grid : Array(Array(T)))
      @height = grid.size
      @width = (grid[0]? || [] of T).size
      @csum = Array.new(@height + 1){ Array.new(@width + 1){ T.zero } }
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
    # csum = StaticRectangleSum.new(a)
    # csum.get?(0...h, j..j + 2) # => 28
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
  end
end
