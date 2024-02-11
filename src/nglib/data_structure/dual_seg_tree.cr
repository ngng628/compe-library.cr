module NgLib
  # 区間作用・$1$ 点取得ができるセグメント木です。
  #
  # 作用素 $f$ は、要素 $x$ と同じ型である必要があります。
  class DualSegTree(T)
    include Indexable(T)
    include Indexable::Mutable(T)

    getter size : Int32
    @n_leaves : Int32
    @rank : Int32
    @nodes : Array(T?)

    # 作用素 $f(x) = x + f$ とした双対セグメント木を作ります。
    def self.range_add(values : Array(T))
      self.new(values) { |applicator, value| value + applicator }
    end

    # :ditto:
    def self.range_add(size : Int)
      self.new(size) { |applicator, value| value + applicator }
    end

    # 作用素 $f(x) = f$ とした双対セグメント木を作ります。
    def self.range_update(values : Array(T))
      self.new(values) { |applicator, _value| applicator }
    end

    # :ditto:
    def self.range_update(size : Int)
      self.new(size) { |applicator, _value| applicator }
    end

    # 作用素 $f(x) = \min(f, x)$ とした双対セグメント木を作ります。
    def self.range_chmin(values : Array(T))
      self.new(values) { |applicator, value| {applicator, value}.min }
    end

    # :ditto:
    def self.range_chmin(size : Int)
      self.new(size) { |applicator, value| {applicator, value}.min }
    end

    # 作用素 $f(x) = \max(f, x)$ とした双対セグメント木を作ります。
    def self.range_chmax(values : Array(T))
      self.new(values) { |applicator, value| {applicator, value}.max }
    end

    # :ditto:
    def self.range_chmax(size : Int)
      self.new(size) { |applicator, value| {applicator, value}.max }
    end

    # 作用素を $f$ とした、要素数 $n$ の双対セグメント木を作ります。
    #
    # 各要素は単位元を表す `nil` で初期化されます。
    #
    # ```
    # seg = NgLib::DualSegTree(Int32).new(5) { |f, x| x + f }
    # seg # => [nil, nil, nil, nil, nil]
    # ```
    def initialize(size : Int, &@application : T, T -> T)
      @size = size.to_i32
      @n_leaves = 1
      @rank = 0
      while @n_leaves < @size
        @n_leaves *= 2
        @rank += 1
      end
      @nodes = Array(T?).new(@n_leaves * 2) { nil }
    end

    # 作用素を $f$ とした、$i$ 番目の要素が `values[i]` の双対セグメント木を作ります。
    #
    # ```
    # seg = NgLib::DualSegTree(Int32).new([*(1..5)]) { |f, x| x + f }
    # seg # => [1, 2, 3, 4, 5]
    # ```
    def initialize(values : Array(T), &@application : T, T -> T)
      @size = values.size
      @n_leaves = 1
      @rank = 0
      while @n_leaves < @size
        @n_leaves *= 2
        @rank += 1
      end
      @nodes = Array(T?).new(@n_leaves * 2) { nil }
      values.each_with_index do |elem, i|
        @nodes[i + @n_leaves] = elem
      end
    end

    def unsafe_fetch(index : Int)
      node_index = index + @n_leaves
      push(node_index)
      @nodes[node_index]
    end

    def unsafe_put(index : Int, value : T)
      node_index = index + @n_leaves
      push(node_index)
      @nodes[node_index] = value
    end

    # `#apply` へのエイリアスです。
    #
    # ```
    # seg = NgLib::DualSegTree(Int32).new([*(1..5)]) { |f, x| x + f }
    # seg # => [1, 2, 3, 4, 5]
    # seg[0...2] = 10
    # seg # => [11, 12, 3, 4, 5]
    # ```
    def []=(range : Range(Int?, Int?), applicator : T)
      apply(range, applicator)
    end

    # `#apply` へのエイリアスです。
    #
    # ```
    # seg = NgLib::DualSegTree(Int32).new([*(1..5)]) { |f, x| x + f }
    # seg # => [1, 2, 3, 4, 5]
    # seg[0, 2] = 10
    # seg # => [11, 12, 3, 4, 5]
    # ```
    def []=(start : Int, count : Int, applicator : T)
      apply(start, count, applicator)
    end

    # `range` の表す区間に `applicator` を作用させます。
    #
    # ```
    # seg = NgLib::DualSegTree(Int32).new([*(1..5)]) { |f, x| x + f }
    # seg # => [1, 2, 3, 4, 5]
    # seg.apply(0...2, 10)
    # seg # => [11, 12, 3, 4, 5]
    # ```
    def apply(range : Range(Int?, Int?), applicator : T)
      l = (range.begin || 0)
      r = (range.end || @size) + (range.exclusive? || range.end.nil? ? 0 : 1)
      return if l >= r

      l += @n_leaves
      r += @n_leaves
      push(l >> l.to_i32.trailing_zeros_count)
      push((r >> r.to_i32.trailing_zeros_count) - 1)
      while l < r
        if l.odd?
          x = @nodes[l]
          apply_impl(l, applicator, x)
          l += 1
        end
        if r.odd?
          r -= 1
          x = @nodes[r]
          apply_impl(r, applicator, x)
        end
        l >>= 1
        r >>= 1
      end

      self
    end

    # `start` 番目から `count` 個までの各要素に `applicator` を作用させます。
    #
    # ```
    # seg = NgLib::DualSegTree(Int32).new([*(1..5)]) { |f, x| x + f }
    # seg # => [1, 2, 3, 4, 5]
    # seg.apply(0, 2, 10)
    # seg # => [11, 12, 3, 4, 5]
    # ```
    def apply(start : Int, count : Int, application : T)
      apply((start...{start + count, @size}.min), application)
    end

    # すべての要素に `application` を作用させます。
    #
    # ```
    # seg = NgLib::DualSegTree(Int32).new([*(1..5)]) { |f, x| x + f }
    # seg # => [1, 2, 3, 4, 5]
    # seg.all_apply(10)
    # seg # => [11, 12, 13, 14, 15]
    # ```
    def apply_all(applicator : T)
      apply(.., applicator)
    end

    def to_s(io : IO)
      (0...@size).map { |i| self[i] || 'e' }.to_a.to_s(io)
    end

    private def push(node_index : Int)
      return if node_index.zero?
      r = 31 - node_index.to_i32.leading_zeros_count
      r.downto(1) do |i|
        j = node_index >> i
        f = @nodes[j]
        {2*j, 2*j + 1}.each do |child|
          x = @nodes[child]
          apply_impl(child, f, x)
        end
        @nodes[j] = nil
      end
    end

    @[AlwaysInline]
    private def apply_impl(node_index : Int, applicator : T?, value : T?)
      return if applicator.nil?
      @nodes[node_index] = value.nil? ? applicator : @application.call(applicator, value)
    end
  end
end
