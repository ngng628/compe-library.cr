require "./succinct_bit_vector.cr"

module NgLib
  # **非負整数列** $A$ に対して次の機能を提供します。
  #
  #
  # ジェネリクス T は `#[]` などでの返却値の型を指定するものであって、
  # 数列の値は非負整数でなければならないことに注意してください。
  class WaveletMatrix(T)
    @values : Array(UInt64)
    @n_nodes : Int32
    @bit_vectors : Array(NgLib::SuccinctBitVector)

    delegate size, to: @values

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

    def self.new(n : Int, & : Int32 -> T)
      WaveletMatrix.new(Array.new(n) { |i| yield i })
    end

    def [](i : Int)
      ret = T.zero
      (@n_nodes - 1).downto(0) do |height|
        bit = @bit_vectors[height][i]
        ret |= (T.zero.succ << height) if bit == 1
        if bit == 1
          ones = @bit_vectors[height].count_ones(0...i)
          zeros = @bit_vectors[height].count_zeros
          i = ones + zeros
        else
          i = @bit_vectors[height].count_zeros(0...i)
        end
      end
      ret
    end

    def ktheight_smallest(ktheight : Int32)
      ktheight_smallest(ktheight, ..)
    end

    def ktheight_smallest(range : Range(Int?, Int?), ktheight : Int)
      l = (range.begin || 0)
      r = (range.end || size) + (range.exclusive? || range.end.nil? ? 0 : 1)

      ret = T.zero
      (@n_nodes - 1).downto(0) do |height|
        lzeros, rzeros = succ0(l, r, height)

        if ktheight < rzeros - lzeros
          l, r = lzeros, rzeros
        else
          ktheight -= rzeros - lzeros
          ret |= T.zero.succ << height
          l += @bit_vectors[height].count_zeros - lzeros
          r += @bit_vectors[height].count_zeros - rzeros
        end
      end

      ret
    end

    def ktheight_largest(ktheight : Int32)
      ktheight_largest(ktheight, ..)
    end

    def ktheight_largest(range : Range(Int?, Int?), ktheight : Int)
      ktheight_smallest(range, range.size - ktheight - 1)
    end

    def count(range : Range(Int?, Int?), bound : Range(T?, T?)) : Int32
      lower_bound = (bound.begin || 0)
      upper_bound = (bound.end || T::MAX) + (bound.exclusive? || bound.end.nil? ? 0 : 1)
      count_impl(range, upper_bound) - count_impl(range, lower_bound)
    end

    def prev_value(range : Range(Int?, Int?), upper_bound) : T?
      cnt = count_impl(range, upper_bound)
      cnt == 0 ? nil : ktheight_smallest(range, cnt - 1)
    end

    def next_value(range : Range(Int?, Int?), lower_bound) : T?
      l = (range.begin || 0)
      r = (range.end || size) + (range.exclusive? || range.end.nil? ? 0 : 1)
      cnt = count_impl(range, lower_bound)
      cnt == (l...r).size ? nil : ktheight_smallest(range, cnt)
    end

    @[AlwaysInline]
    private def log2_floor(n : UInt64) : Int32
      log2_floor = 63 - n.leading_zeros_count
      log2_floor + ((n & n - 1) == 0 ? 0 : 1)
    end

    @[AlwaysInline]
    private def succ0(left : Int, righeightt : Int, height : Int)
      lzeros = @bit_vectors[height].count_zeros(0...left)
      rzeros = @bit_vectors[height].count_zeros(0...righeightt)
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
