module NgLib
  # 不変な数列 $A$ に対して、$\sum_{i=l}^{r-1} A_i$ を前計算 $O(N)$ クエリ $O(1)$ で求めます。
  class StaticRangeSum(T)
    getter size : Int64
    getter csum : Array(T)

    # 配列 `array` に対して累積和を構築します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = StaticRangeSum(Int32).new(array)
    # ```
    def initialize(array : Array(T))
      @size = array.size.to_i64
      @csum = Array.new(@size + 1, T.zero)
      @size.times { |i| @csum[i + 1] = @csum[i] + array[i] }
    end

    # self[0...r] >= x を満たす最小の self[0...r]
    def lower_bound(x)
      ac = @size + 1
      wa = 0
      while ac - wa > 1
        wj = ac + (wa - ac) // 2
        if self[0...wj] >= x
          ac = wj
        else
          wa = wj
        end
      end
      ac == @size + 1 ? nil : self[0...ac]
    end

    # self[0...r] >= x を満たす最小の r を返します。
    def lower_bound_index(x)
      ac = @size + 1
      wa = 0
      while ac - wa > 1
        wj = ac + (wa - ac) // 2
        if self[0...wj] >= x
          ac = wj
        else
          wa = wj
        end
      end
      ac == @size + 1 ? nil : ac
    end

    # self[0...r] > x を満たす最小の self[0...r]
    def upper_bound(x)
      ac = @size + 1
      wa = 0
      while ac - wa > 1
        wj = ac + (wa - ac) // 2
        if self[0...wj] > x
          ac = wj
        else
          wa = wj
        end
      end
      ac == @size + 1 ? nil : self[0...ac]
    end

    # self[0...r] > x を満たす最小の r を返します。
    def upper_bound_index(x)
      ac = @size + 1
      wa = 0
      while ac - wa > 1
        wj = ac + (wa - ac) // 2
        if self[0...wj] > x
          ac = wj
        else
          wa = wj
        end
      end
      ac == @size + 1 ? nil : ac
    end

    # $[l, r)$ 番目までの要素の総和 $\sum_{i=l}^{r-1} a_i$ を $O(1)$ で返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = StaticRangeSum(Int32).new(array)
    # csum.get(0...5) # => 1 + 1 + 2 + 3 + 5 = 12
    # ```
    def get(l, r) : T
      raise IndexError.new("`l` must be less than or equal to `r` (#{l}, #{r})") unless l <= r
      @csum[r] - @csum[l]
    end

    # :ditto:
    def get(range : Range(Int?, Int?)) : T
      l = (range.begin || 0)
      r = (range.end || @size) + (range.exclusive? || range.end.nil? ? 0 : 1)
      get(l, r)
    end

    # $[l, r)$ 番目までの要素の総和 $\sum_{i=l}^{r-1} a_i$ を $O(1)$ で返します。
    #
    # $l \leq r$ を満たさないとき、`nil` を返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = StaticRangeSum(Int32).new(array)
    # csum.get?(0...5) # => 1 + 1 + 2 + 3 + 5 = 12
    # csum.get?(7...5) # => nil
    # ```
    def get?(l, r) : T?
      return nil unless l <= r
      get(l, r)
    end

    # :ditto:
    def get?(range : Range(Int?, Int?)) : T?
      l = (range.begin || 0)
      r = (range.end || @size) + (range.exclusive? || range.end.nil? ? 0 : 1)
      get?(l, r)
    end

    # $\sum_{i=1}^{r - 1} a_i - \sum_{i=1}^{l} a_i$ を $O(1)$ で返します。
    def get!(l, r) : T
      @csum[r] - @csum[l]
    end

    # :ditto:
    def get!(range : Range(Int?, Int?)) : T
      l = (range.begin || 0)
      r = (range.end || @size) + (range.exclusive? || range.end.nil? ? 0 : 1)
      get!(l, r)
    end

    # `get(l : Int, r : Int)` へのエイリアスです。
    def [](l, r) : T
      get(l, r)
    end

    # `get(range : Range(Int?, Int?))` へのエイリアスです。
    def [](range : Range(Int?, Int?)) : T
      get(range)
    end

    # `get(l : Int, r : Int)` へのエイリアスです。
    def []?(l, r) : T?
      get?(l, r)
    end

    # `get?(range : Range(Int?, Int?))` へのエイリアスです。
    def []?(range : Range(Int?, Int?)) : T?
      get?(range)
    end
  end
end
