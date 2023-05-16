module NgLib
  # 不変な数列 $A$ について、以下の条件を満たす演算を、区間クエリとして処理します。
  # - 結合則 : $(x \oplus y) \oplus z = x \oplus (y \oplus z)$
  # - 冪等性 : $x \oplus x = x$
  #
  # 前計算は $O(N \log{N}) かかりますが、区間クエリには $O(1)$ で答えられます。
  class SparseTable(T)
    getter size : Int32
    @data : Array(T)
    @table : Array(Array(T))
    @lookup : Array(Int32)
    @op : (T, T) -> T

    # $\oplus = \max$ としてデータ構造を構築します。
    def self.max(elems : Enumerable(T))
      new elems, ->(x : T, y : T){ x > y ? x : y }
    end

    # $\oplus = \min$ としてデータ構造を構築します。
    def self.min(elems : Enumerable(T))
      new elems, ->(x : T, y : T){ x < y ? x : y }
    end

    # $\oplus = \mathrm{bitwise-or}$ としてデータ構造を構築します。
    def self.bitwise_or(elems : Enumerable(T))
      new elems, ->(x : T, y : T){ x | y }
    end

    # $\oplus = \mathrm{bitwise-and}$ としてデータ構造を構築します。
    def self.bitwise_and(elems : Enumerable(T))
      new elems, ->(x : T, y : T){ x & y }
    end

    # $\oplus = \mathrm{gcd}$ としてデータ構造を構築します。
    def self.gcd(elems : Enumerable(T))
      new elems, ->(x : T, y : T){ x.gcd(y) }
    end

    # $\oplus = op$ としてデータ構造を構築します。
    def initialize(elems : Enumerable(T), @op : (T, T) -> T)
      @size = elems.size
      @data = Array(T).new
      log = (0..).index{ |k| (1 << k) > @size }.not_nil!

      @table = Array.new(log){ Array(T).new(1 << log, T.zero) }
      elems.each_with_index{ |e, i| @table[0][i] = e; @data << e }

      (1...log).each do |i|
        j = 0
        while j + (1 << i) <= (1 << log)
          @table[i][j] = @op.call(@table[i - 1][j], @table[i - 1][j + (1 << (i - 1))])
          j += 1
        end
      end

      @lookup = [0] * (@size + 1)
      (2..@size).each do |i|
        @lookup[i] = @lookup[i >> 1] + 1
      end
    end

    # `range` の表す範囲の要素の総積 $\bigoplus_{i \in range} a_i$ を返します。
    #
    # ```
    # rmq = SparseTable(Int32).min([2, 7, 1, 8, 1])
    # rmq.prod(0...3) # => 1
    # ```
    def prod(range : Range(Int?, Int?))
      l = (range.begin || 0)
      r = if range.end.nil?
          @size
        else
          range.end.not_nil! + (range.exclusive? ? 0 : 1)
        end

      b = @lookup[r - l]
      @op.call(@table[b][l], @table[b][r - (1 << b)])
    end

    # `range` の表す範囲の要素の総積 $\bigoplus_{i \in range} a_i$ を返します。
    #
    # $0 \leq l \leq r \leq n$ を満たさないとき、`nil` を返します。
    #
    # ```
    # rmq = SparseTable(Int32).min([2, 7, 1, 8, 1])
    # rmq.prod(0...3) # => 1
    # ```
    def prod?(range : Range(Int?, Int?))
      l = (range.begin || 0)
      r = if range.end.nil?
          @size
        else
          range.end.not_nil! + (range.exclusive? ? 0 : 1)
        end

      return nil unless 0 <= l && l <= r && r <= @size
      prod(range)
    end

    # $a_i$ を返します。
    def [](i)
      @data[i]
    end

    # $a_i$ を返します。
    #
    # 添字が範囲外のとき、`nil` を返します。
    def []?(i)
      @data[i]?
    end

    # `prod` へのエイリアスです。
    def [](range : Range(Int?, Int?))
      prod(range)
    end

    # `prod?` へのエイリアスです。
    def []?(range : Range(Int?, Int?))
      prod?(range)
    end
  end
end
