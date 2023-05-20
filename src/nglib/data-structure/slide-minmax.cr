module NgLib
  # データ列 $a$ に対して、$\min(a_i, a_{i + 1}, \dots, a_{i + \mathrm{length} - 1})$ を求めるためのデータ構造です。
  #
  # セグメント木やSparseTableと異なり、区間長が固定の範囲でしかクエリに答えられませんが、
  # 計算量が前計算 $O(N)$ で、クエリが $O(1)$ なので高速です。
  #
  # `query(i)` で $[i, i + \mathrm{length} - 1)$ が配列の範囲を超えたとき、$[i, \mathrm{a.size})$ だと思って計算します。
  #
  # もし、`query(i)` で $[i - \mathrm{length}, i)$ が求まってほしい場合は、`a = ([eins] * length) + a` としておけば良いです。
  # 範囲外の場合は $[0, i)$ だと思って計算されます。
  #
  # なお、$[0, 0)$ の場合は単位元が返ります。
  #
  # もし、query(i) で $[i - \mathrm{length}, i]$ が求まってほしい場合は、`a = ([eins] * (length - 1)) + a` としておけば良いです。
  # 範囲外の場合は $[0, i]$ だと思って計算されます。
  class SlideMinmax(T)
    @length : Int32
    @data : Array(T)

    # データ列 $a$ に対して、$\min(a_i, a_{i + 1}, \dots, a_{i + \mathrm{length} - 1})$ を求めるためのデータ構造を構築します。
    #
    # ```
    # rmq = SlideMinmax(Int32).min([2, 7, 3, 4, 6], 3)
    # ```
    def self.min(a : Array(T), length : Int)
      new(a, length, T::MAX) { |lhs, rhs| lhs <= rhs }
    end

    # データ列 $a$ に対して、$\max(a_i, a_{i + 1}, \dots, a_{i + \mathrm{length} - 1})$ を求めるためのデータ構造を構築します。
    #
    # ```
    # rmq = SlideMinmax(Int32).max([2, 7, 3, 4, 6], 3)
    # ```
    def self.max(a : Array(T), length : Int)
      new(a, length, T::MIN) { |lhs, rhs| lhs >= rhs }
    end

    # データ列 $a$ に対して、$cmp(a_i, a_{i + 1}, \dots, a_{i + \mathrm{length} - 1})$ を求めるためのデータ構造を構築します。
    #
    # `eins` には `@cmp` に対する単位元を渡してください。
    #
    # この API は非推奨です。`self.min` または `self.max` を使用してください。
    #
    # ```
    # rmq = SlideMinmax(Int32).new([2, 7, 3, 4, 6], 3) { |a, b| a <= b } # => min query
    # ```
    def initialize(a : Array(T), length : Int, eins : T, &@cmp : (T, T) -> Bool)
      a.concat([eins] * (length - 1))
      @length = length.to_i32
      @data = Array(T).new(a.size)

      tops = Deque(Int32).new
      a.each_with_index do |e, i|
        while !tops.empty? && @cmp.call(e, a[tops.last])
          tops.pop
        end
        tops << i
        if i - length + 1 >= 0
          @data << a[tops.first]
          if tops.first == i - length + 1
            tops.shift
          end
        end
      end
    end

    # $[i, i + \mathrm{length})$ の範囲の総積 $cmp(a_i, a_{i + 1}, \dots, a_{i + \mathrm{length} - 1})$ を求めます。
    #
    # $i + \mathrm{length}$ が $a$ のサイズを超える場合は、$[i, \mathrm{a.size})$ で求めます。
    #
    # ```
    # rmq = SlideMinmax(Int32).min([2, 7, 3, 4, 6], 3)
    # rmq.query(0) # => 2
    # rmq.query(1) # => 3
    # rmq.query(2) # => 3
    # rmq.query(3) # => 4
    # rmq.query(4) # => 6
    # ```
    def query(i : Int) : T
      @data[i]
    end

    # $[i, i + \mathrm{length})$ の範囲の総積 $cmp(a_i, a_{i + 1}, \dots, a_{i + \mathrm{length} - 1})$ を求めます。
    #
    # $i + \mathrm{length}$ が $a$ のサイズを超える場合は、$[i, \mathrm{a.size})$ で求めます。
    #
    # 配列外参照の場合は `nil` を返します。
    #
    # ```
    # rmq = SlideMinmax(Int32).min([2, 7, 3, 4, 6], 3)
    # rmq.query?(0)   # => 2
    # rmq.query?(1)   # => 3
    # rmq.query?(2)   # => 3
    # rmq.query?(3)   # => 4
    # rmq.query?(4)   # => 6
    # rmq.query?(100) # => nil
    # ```
    def query?(i : Int) : T?
      @data[i]?
    end
  end
end
