require "./succinct_bit_vector.cr"

module NgLib
  # **非負整数列** $A$ に対して、順序に関する様々なクエリに答えます。
  #
  # ジェネリクス T は `#[]` などでの返却値の型を指定するものであって、
  # 数列の値は非負整数でなければならないことに注意してください。
  class WaveletMatrix(T)
    include Indexable(T)

    @values : Array(UInt64)
    @n_nodes : Int32
    @bit_vectors : Array(NgLib::SuccinctBitVector)

    delegate size, to: @values

    # 非負整数列 $A$ を `values` によって構築します。
    #
    # ```
    # WaveletMatrix.new([1, 3, 2, 5])
    # ```
    def initialize(values : Array(T))
      n = values.size
      @values = values.map(&.to_u64)
      @n_nodes = log2_floor({1_u64, @values.max}.max) + 1
      @bit_vectors = Array.new(@n_nodes) { NgLib::SuccinctBitVector.new(n) }

      cur = @values.clone
      nxt = Array.new(n) { 0_u64 }
      (@n_nodes - 1).downto(0) do |height|
        n.times do |i|
          @bit_vectors[height].set(i) if cur[i].bit(height) == 1
        end

        @bit_vectors[height].build

        indices = [0, @bit_vectors[height].count_zeros]
        n.times do |i|
          bit = @bit_vectors[height][i]
          nxt[indices[bit]] = cur[i]
          indices[bit] += 1
        end

        cur, nxt = nxt, cur
      end
    end

    # 長さ $n$ の非負整数列 $A$ を構築します。
    #
    # ```
    # WaveletMatrix.new(10) { |i| (5 - i) ** 2 }
    # ```
    def self.new(n : Int, & : Int32 -> T)
      WaveletMatrix.new(Array.new(n) { |i| yield i })
    end

    # $A$ の `index` 番目の要素を取得します。
    #
    # ```
    # wm = WaveletMatrix.new([1, 3, 2, 5])
    # wm.unsafe_fetch(0) # => 1
    # wm.unsafe_fetch(1) # => 3
    # wm.unsafe_fetch(2) # => 2
    # wm.unsafe_fetch(3) # => 5
    # ```
    def unsafe_fetch(index : Int)
      @values.unsafe_fetch(index)
    end

    # `kth` 番目に小さい値を返します。
    #
    # ```
    # wm = WaveletMatrix.new([1, 3, 2, 5])
    # wm.kth_smallest(0) # => 1
    # wm.kth_smallest(1) # => 2
    # wm.kth_smallest(2) # => 3
    # wm.kth_smallest(3) # => 5
    # ```
    def kth_smallest(kth : Int32)
      kth_smallest(kth, ..)
    end

    # `range` の表す区間に含まれる要素のうち、`kth` 番目に小さい値を返します。
    #
    # ```
    # wm = WaveletMatrix.new([1, 3, 2, 5])
    # wm.kth_smallest(1..2, 0) # => 2
    # wm.kth_smallest(1..2, 1) # => 3
    # ```
    def kth_smallest(range : Range(Int?, Int?), kth : Int)
      l = (range.begin || 0)
      r = (range.end || size) + (range.exclusive? || range.end.nil? ? 0 : 1)

      ret = T.zero
      (@n_nodes - 1).downto(0) do |height|
        lzeros, rzeros = succ0(l, r, height)

        if kth < rzeros - lzeros
          l, r = lzeros, rzeros
        else
          kth -= rzeros - lzeros
          ret |= T.zero.succ << height
          l += @bit_vectors[height].count_zeros - lzeros
          r += @bit_vectors[height].count_zeros - rzeros
        end
      end

      ret
    end

    # `kth` 番目に大きい値を返します。
    #
    # ```
    # wm = WaveletMatrix.new([1, 3, 2, 5])
    # wm.kth_smallest(0) # => 5
    # wm.kth_smallest(1) # => 3
    # wm.kth_smallest(2) # => 2
    # wm.kth_smallest(3) # => 1
    # ```
    def kth_largest(kth : Int32)
      kth_largest(kth, ..)
    end

    # `range` の表す区間に含まれる要素のうち、`kth` 番目に大きい値を返します。
    #
    # ```
    # wm = WaveletMatrix.new([1, 3, 2, 5])
    # wm.kth_largest(1..2, 0) # => 3
    # wm.kth_largest(1..2, 1) # => 2
    # ```
    def kth_largest(range : Range(Int?, Int?), kth : Int)
      kth_smallest(range, range.size - kth - 1)
    end

    # `item` の個数を返します。
    # 
    # 計算量は対数オーダーです。
    def count(item : T)
      count(.., item)
    end

    # `range` の表す区間に含まれる要素の中で `item` の個数を返します。
    def count(range : Range(Int?, Int?), item : T)
      count(range, item..item)
    end

    # `range` の表す区間に含まれる要素の中で `bound` が表す範囲の値の個数を返します。
    def count(range : Range(Int?, Int?), bound : Range(T?, T?)) : Int32
      lower_bound = (bound.begin || 0)
      upper_bound = (bound.end || T::MAX) + (bound.exclusive? || bound.end.nil? ? 0 : 1)
      count_impl(range, upper_bound) - count_impl(range, lower_bound)
    end

    # `range` の表す区間に含まれる要素のうち、`upper_bound` **未満** の値の最大値を返します。
    #
    # 存在しない場合は `nil` を返します。
    def prev_value(range : Range(Int?, Int?), upper_bound) : T?
      cnt = count_impl(range, upper_bound)
      cnt == 0 ? nil : kth_smallest(range, cnt - 1)
    end

    # `range` の表す区間に含まれる要素のうち、`lower_bound` **以上** の値の最小値を返します。
    #
    # 存在しない場合は `nil` を返します。
    def next_value(range : Range(Int?, Int?), lower_bound) : T?
      l = (range.begin || 0)
      r = (range.end || size) + (range.exclusive? || range.end.nil? ? 0 : 1)
      cnt = count_impl(range, lower_bound)
      cnt == (l...r).size ? nil : kth_smallest(range, cnt)
    end

    @[AlwaysInline]
    private def log2_floor(n : UInt64) : Int32
      log2_floor = 63 - n.leading_zeros_count
      log2_floor + ((n & n - 1) == 0 ? 0 : 1)
    end

    @[AlwaysInline]
    private def succ0(left : Int, right : Int, height : Int)
      lzeros = left <= 0 ? 0 : @bit_vectors[height].count_zeros(0...Math.min(left, size))
      rzeros = right <= 0 ? 0 : @bit_vectors[height].count_zeros(0...Math.min(right, size))
      {lzeros, rzeros}
    end

    private def count_impl(range : Range(Int?, Int?), upper_bound) : Int32
      l = (range.begin || 0)
      r = (range.end || size) + (range.exclusive? || range.end.nil? ? 0 : 1)

      return (l...r).size.to_i if upper_bound >= (T.zero.succ << @n_nodes)

      ret = 0
      (@n_nodes - 1).downto(0) do |height|
        lzeros, rzeros = succ0(l, r, height)
        if upper_bound.bit(height) == 1
          ret += rzeros - lzeros
          l += @bit_vectors[height].count_zeros - lzeros
          r += @bit_vectors[height].count_zeros - rzeros
        else
          l, r = lzeros, rzeros
        end
      end

      ret
    end
  end
end
