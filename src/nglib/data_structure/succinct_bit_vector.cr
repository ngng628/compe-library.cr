module NgLib
  # `SuccinctBitVector` は簡易ビットベクトル（簡易辞書、Succinct Indexable Dictionary）を提供するクラスです。
  #
  # 前計算 $O(n / 32)$ で次の操作が $O(1)$ くらいでできます。
  #
  # - `.[i]` # => $i$ 番目のビットにアクセスする （$O(1)$）
  # - `.sum(r)` # =>  $[0, r)$ にある $1$ の個数を求める （$O(1)$）
  # - `.kth_bit_index(k)` # => $k$ 番目に現れる $1$ の位置を求める （$O(\log{n})$）
  #
  # 例えばこの問題が解けます → [D - Sleep Log](https://atcoder.jp/contests/abc305/tasks/abc305_d)
  class SuccinctBitVector
    getter size : UInt32
    @blocks : UInt32
    @bits : Array(UInt32)
    @sums : Array(UInt32)

    # 長さ $n$ のビット列を構築します。
    #
    # 計算量は $O(n / 32)$ です。
    def initialize(n : Int)
      @size = n.to_u32
      @blocks = (@size + 31) >> 5
      @bits = [0_u32] * @blocks
      @sums = [0_u32] * @blocks
    end

    # 長さ $n$ のビット列を構築します。
    #
    # ブロックでは $i$ 番目のビットの値を返してください。
    #
    # 計算量は $O(n)$ です。
    def initialize(n : Int, & : -> Int)
      @size = n.to_u32
      @blocks = (@size + 31) >> 5
      @bits = [0_u32] * @blocks
      @sums = [0_u32] * @blocks

      @size.times do |i|
        set i if (yield i) == 1
      end

      build
    end

    # 左から $i$ 番目のビットを 1 にします。
    #
    # 計算量は $O(1)$ です。
    def set(i : Int)
      @bits[i >> 5] |= 1_u32 << (i & 31)
    end

    # 左から $i$ 番目のビットを 0 にします。
    #
    # 計算量は $O(1)$ です。
    def reset(i : Int)
      @bits[i >> 5] &= ~(1_u32 << (i & 31))
    end

    # 総和が計算できるようにデータ構造を構築します。
    def build
      @sums[0] = 0
      (1...@blocks).each do |i|
        @sums[i] = @sums[i - 1] + @bits[i - 1].popcount
      end
    end

    # $[0, n)$ の総和を返します。
    def sum
      sum(n)
    end

    # $[0, r)$ の総和を返します。
    def sum(r) : UInt32
      @sums[r >> 5] + (@bits[r >> 5] & ((1_u32 << (r & 31)) - 1)).popcount
    end

    # $[l, r)$ の総和を返します。
    def sum(l, r) : UInt32
      sum(r) - sum(l)
    end

    # `range` の範囲で総和を返します。
    def sum(range : Range(Int?, Int?))
      l = (range.begin || 0)
      r = if range.end.nil?
            @size
          else
            range.end.not_nil! + (range.exclusive? ? 0 : 1)
          end
      sum(l, r)
    end

    # $i$ 番目のビットを返します。
    def [](i) : UInt32
      ((@bits[i >> 5] >> (i & 31)) & 1) > 0 ? 1_u32 : 0_u32
    end

    # `range` の範囲の総和を返します。
    def [](range : Range(Int?, Int?)) : UInt32
      sum(range)
    end

    # $k$ 番目に出現する $1$ の位置を求めます。
    #
    # 言い換えると、$sum(i) = k$ となるような最小の $i$ を返します。
    #
    # 存在しない場合は `nil` を返します。
    #
    # 本当は $O(1)$ にできるらしいですが、面倒なので $O(\log{n})$ です。
    def kth_bit_index(k) : UInt32
      return 0_u32 if k == 0
      return nil if sum < k

      (0..length).bsearch { |r|
        sum(r) >= k
      }.not_nil!
    end
  end
end
