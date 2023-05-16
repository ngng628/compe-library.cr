module NgLib
  class DynamicRangeSum(T)
    getter size : Int32
    @data : Array(T)

    # 長さが $n$ で各要素が $0$ の数列 $a$ を構築します。
    def initialize(n : Int)
      @data = Array(T).new(n){ T.zero }
      @size = @data.size
    end

    # 長さが $n$ で各要素が $val$ の数列 $a$ を構築します。
    def initialize(n : Int, val : T)
      @data = Array(T).new(n){ val }
      @size = @data.size
    end

    # 長さが $n$ で $i$ 番目の要素が $elems_i$ の数列 $a$ を構築します。
    def initialize(elems : Enumerable(T))
      @size = elems.size.to_i32
      @data = Array(T).new(@size, T.zero)
      elems.each_with_index{ |x, i| add(i, x) }
    end

    # $[l, r)$ 番目までの要素の総和 $\sum_{i=l}^{r-1} a_i$ を $O(\log{N})$ で返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum.get(0, 5) # => 1 + 1 + 2 + 3 + 5 = 12
    # ```
    def get(l, r) : T
      raise IndexError.new("`l` and `r` must be 0 <= l <= r <= self.size (#{l}, #{r})") unless 0 <= l && l <= r && r <= @size
      sum(r) - sum(l)
    end

    # $[l, r)$ 番目までの要素の総和 $\sum_{i=l}^{r-1} a_i$ を $O(\log{N})$ で返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum[0, 5] # => 1 + 1 + 2 + 3 + 5 = 12
    # ```
    def [](l, r) : T
      get(l, r)
    end

    # `range` の表す範囲の要素の総和 $\sum_{i \in range} a_i$ を $O(\log{N})$ で返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum.get(0...5) # => 1 + 1 + 2 + 3 + 5 = 12
    # ```
    def get(range : Range(Int?, Int?)) : T
      l = (range.begin || 0)
      r = range.end ? range.end.not_nil! + (range.exclusive? ? 0 : 1) : @size
      get(l, r)
    end

    # `range` の表す範囲の要素の総和 $\sum_{i \in range} a_i$ を $O(\log{N})$ で返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum[0...5] # => 1 + 1 + 2 + 3 + 5 = 12
    # ```
    def [](range : Range(Int?, Int?)) : T
      l = (range.begin || 0)
      r = range.end ? range.end.not_nil! + (range.exclusive? ? 0 : 1) : @size
      get(l, r)
    end

    # $[l, r)$ 番目までの要素の総和 $\sum_{i=l}^{r-1} a_i$ を $O(\log{N})$ で返します。
    #
    # $0 \leq l \leq r \leq n$ を満たさないとき、`nil` を返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum.get?(0, 5) # => 1 + 1 + 2 + 3 + 5 = 12
    # csum.get?(7, 3) # => nil
    # ```
    def get?(l, r) : T?
      return nil unless 0 <= l && l <= r && r <= @size
      get(l, r)
    end

    # $[l, r)$ 番目までの要素の総和 $\sum_{i=l}^{r-1} a_i$ を $O(\log{N})$ で返します。
    #
    # $0 \leq l \leq r \leq n$ を満たさないとき、`nil` を返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum[0, 5]? # => 1 + 1 + 2 + 3 + 5 = 12
    # csum[7, 3]? # => nil
    # ```
    def []?(l, r) : T?
      get?(l, r)
    end

    # `range` の表す範囲の要素の総和 $\sum_{i \in range} a_i$ を $O(\log{N})$ で返します。
    #
    # $0 \leq l \leq r \leq n$ を満たさないとき、`nil` を返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum.get?(0...5) # => 1 + 1 + 2 + 3 + 5 = 12
    # csum.get?(7...3) # => nil
    # ```
    def get?(range : Range(Int?, Int?)) : T
      l = (range.begin || 0)
      r = range.end ? range.end.not_nil! + (range.exclusive? ? 0 : 1) : @size
      get?(l, r)
    end

    # `range` の表す範囲の要素の総和 $\sum_{i \in range} a_i$ を $O(\log{N})$ で返します。
    #
    # $0 \leq l \leq r \leq n$ を満たさないとき、`nil` を返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum[0...5]? # => 1 + 1 + 2 + 3 + 5 = 12
    # csum[7...3]? # => nil
    # ```
    def []?(range : Range(Int?, Int?)) : T
      l = (range.begin || 0)
      r = range.end ? range.end.not_nil! + (range.exclusive? ? 0 : 1) : @size
      get?(l, r)
    end

    # $a_i$ を $O(\log{N})$ で返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum.get(5) # => 8
    # ```
    def get(i) : T
      get(i, i + 1)
    end

    # $a_i$ を $O(\log{N})$ で返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum[5] # => 8
    # ```
    def [](i) : T
      get(i, i + 1)
    end

    # $a_i$ を $O(\log{N})$ で返します。
    #
    # $0 \leq i \lt n$ を満たさないとき、`nil` を返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum.get?(5) # => 8
    # csum.get?(10)? # => nil
    # ```
    def get?(i) : T?
      get?(i, i + 1)
    end

    # $a_i$ を $O(\log{N})$ で返します。
    #
    # $0 \leq i \lt n$ を満たさないとき、`nil` を返します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum[5] # => 8
    # csum[10]? # => nil
    # ```
    def []?(i) : T?
      get?(i, i + 1)
    end

    # $a_i$ の値を $x$ に更新します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum.get?(0...5) # => 1 + 1 + 2 + 3 + 5 = 12
    # csum[0] = 100
    # csum.get?(0...5) # => 100 + 1 + 2 + 3 + 5 = 111
    # ```
    def []=(i : Int, x : T) : T
      add(i, x - get(i))
    end

    # $a_i$ の値を $x$ に更新します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum.get?(0...5) # => 1 + 1 + 2 + 3 + 5 = 12
    # csum.set(0, 100)
    # csum.get?(0...5) # => 100 + 1 + 2 + 3 + 5 = 111
    # ```
    def set(i : Int, x : T)
      self[i] = x
    end

    # $a_i$ に $x$ を加算します。
    #
    # ```
    # array = [1, 1, 2, 3, 5, 8, 13]
    # csum = DynamicRangeSum(Int32).new(array)
    # csum.get?(0...5) # => 1 + 1 + 2 + 3 + 5 = 12
    # csum.add(0, 99)
    # csum.get?(0...5) # => 100 + 1 + 2 + 3 + 5 = 111
    # ```
    def add(i : Int, x : T)
      i += 1
      while (i <= @size)
        @data[i - 1] += x
        i += i & -i
      end
      x
    end

    private def sum(r : Int) : T
      s = T.zero
      while r > 0
        s += @data[r - 1]
        r -= r & -r
      end
      s
    end
  end
end
