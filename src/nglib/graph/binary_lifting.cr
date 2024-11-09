module NgLib
  # ダブリングを実現します。
  #
  # ```
  # graph = NgLib::BinaryLifting(Int64).new(n) {
  #   {to[i], weight[i]}
  # }
  #
  # graph.query
  # graph.where
  # graph.weight_sum
  # ```
  class BinaryLifting(T)
    getter size : Int32
    @lim : UInt64
    @log : Int32
    @table : Array(Array({Int32, T}))
    @should_build : Bool

    # n 頂点 0 辺のグラフを作ります。
    #
    # 移動回数の上限を limit で指定します。
    # initial でノードの初期値を指定します。
    #
    # ```
    # n = 10
    # graph = BinaryLifting.new(n)
    # ```
    def initialize(n : Int, limit : Int = UInt64::MAX // 2, initial : T = T.zero)
      @size = n.to_i32
      @lim = limit.to_u64
      @log = impl_log2(limit)
      @table = Array.new(@log) { Array.new(n) { {-1, T.zero} } }
      @should_build = true
    end

    # n 頂点 n 辺のグラフを作ります。
    #
    # ブロックで各 i に対する移動先と重みをタプルで返す必要があります。
    #
    # 移動回数の上限を limit で指定します。
    # initial でノードの初期値を指定します。
    #
    # ```
    # n = 10
    # graph = BinaryLifting.new(n) { |i| {a[i].to_i32, 0} }
    # ```
    def initialize(n : Int, limit : Int = UInt64::MAX // 2, initial : T = T.zero, & : Int32 -> {Int32, T})
      @size = n.to_i32
      @lim = limit.to_u64
      @log = impl_log2(limit)
      @table = Array.new(@log) { |j| Array.new(n) { |i| j == 0 ? (yield i) : {-1, T.zero} } }
      @should_build = true
    end

    # 頂点 s から頂点 t に重み weight の辺を追加します。
    #
    # ```
    # n = 10
    # graph = BinaryLifting.new(n) { |i| {a[i].to_i32, 0} }
    # graph.add_edge(0, 1, 10)
    # graph.add_edge(1, 5, 3)
    # graph.add_edge(5, 1, 2)
    # ```
    def add_edge(s : Int, t : Int, weight : T = T.zero)
      @table[0][s] = {t.to_i32, weight}
      @should_build = true
    end

    # query　が高速にできるよう、データを構築します。
    def build
      (0...@log - 1).each do |k|
        @size.times do |i|
          pre = @table[k][i][0]
          if pre == -1
            @table[k + 1][i] = @table[k][i]
          else
            nxt = @table[k][pre][0]
            w = @table[k][i][1] + @table[k][pre][1]
            @table[k + 1][i] = {nxt, w}
          end
        end
      end
      @should_build = false
    end

    # 頂点 start から times 回移動したときいる場所を返します。
    #
    # ```
    # n = 3
    # graph = BinaryLifting.new(n)
    # graph.add_edge(0, 1, 1)
    # graph.add_edge(1, 2, 10)
    # graph.add_edge(2, 1, 100)
    #
    # graph.where(start: 0, times: 5) # => 2
    # graph.where(start: 1, times: 5) # => 0
    # ```
    def where(start : Int, times : Int)
      build if @should_build
      query(start, times)[1]
    end

    # 頂点 start から times 回移動したときいる場所を返します。
    #
    # build 済みかの確認を行いません。
    #
    # ```
    # n = 3
    # graph = BinaryLifting.new(n)
    # graph.add_edge(0, 1, 1)
    # graph.add_edge(1, 2, 10)
    # graph.add_edge(2, 0, 100)
    #
    # graph.where!(start: 0, times: 5) # => 2
    # graph.where!(start: 1, times: 5) # => 0
    # ```
    def where!(start : Int, times : Int)
      query!(start, times)[1]
    end

    # 頂点 start から times 回移動する経路中の重みの総和を返します。
    #
    # ```
    # n = 3
    # graph = BinaryLifting.new(n)
    # graph.add_edge(0, 1, 1)
    # graph.add_edge(1, 2, 10)
    # graph.add_edge(2, 0, 100)
    #
    # graph.weight_sum(start: 0, times: 5) # => 122
    # graph.weight_sum(start: 1, times: 5) # => 221
    # ```
    def weight_sum(start : Int, times : Int)
      build if @should_build
      query(start, times)[0]
    end

    # 頂点 start から times 回移動する経路中の重みの総和を返します。
    #
    # build 済みかの確認を行いません。
    #
    # ```
    # n = 3
    # graph = BinaryLifting.new(n)
    # graph.add_edge(0, 1, 1)
    # graph.add_edge(1, 2, 10)
    # graph.add_edge(2, 0, 100)
    #
    # graph.weight_sum!(start: 0, times: 5) # => 122
    # graph.weight_sum!(start: 1, times: 5) # => 221
    # ```
    def weight_sum!(start : Int, times : Int)
      query!(start, times)[0]
    end

    # 頂点 start から times 回移動する経路中の重みの総和と場所を返します。
    #
    # ```
    # n = 3
    # graph = BinaryLifting.new(n)
    # graph.add_edge(0, 1, 1)
    # graph.add_edge(1, 2, 10)
    # graph.add_edge(2, 0, 100)
    #
    # graph.query(start: 0, times: 5) # => {2, 122}
    # graph.query(start: 1, times: 5) # => {0, 221}
    # ```
    def query(start : Int, times : Int)
      build if @should_build
      query!(start, times)
    end

    # 頂点 start から times 回移動する経路中の重みの総和と場所を返します。
    #
    # build 済みかの確認を行いません。
    #
    # ```
    # n = 3
    # graph = BinaryLifting.new(n)
    # graph.add_edge(0, 1, 1)
    # graph.add_edge(1, 2, 10)
    # graph.add_edge(2, 0, 100)
    #
    # graph.query!(start: 0, times: 5) # => {2, 122}
    # graph.query!(start: 1, times: 5) # => {0, 221}
    # ```
    def query!(start : Int, times : Int)
      acc = T.zero
      (@log - 1).downto(0).each do |k|
        if times.bit(k) == 1
          acc += @table[k][start][1]
          start = @table[k][start][0]
        end
        break if start == -1
      end
      {acc, start}
    end

    [AlwaysInline]

    def impl_log2(x : Int) : Int32
      Int32.new(sizeof(typeof(x)) * 8 - x.leading_zeros_count)
    end
  end
end
