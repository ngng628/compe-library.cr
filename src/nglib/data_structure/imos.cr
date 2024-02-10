module NgLib
  class Imos(T)
    include Enumerable(T)
  
    getter size : Int32
    @added : Array(T)
    @sums : Array(T)
    @should_build : Bool
  
    def initialize
      @size = 0
      @added = [] of T
      @sums = [] of T
      @should_build = true
    end
  
    def initialize(n : Int)
      @size = n.to_i32
      @added = Array.new(n + 2){ T.zero }
      @sums = [] of T
      @should_build = true
    end
  
    # [l, r) に val を加算します。
    #
    # NOTE: このAPIの使用は推奨されません。Rangeで指定してください。
    def add(l : Int, r : Int, val : T) : T
      @added[l] += val
      @added[r] -= val
      @should_build = true
      val
    end
  
    # range の範囲に val を加算します。
    #
    # ```
    # imos = Imos(Int32).new(n)
    # imos.add(0..n, 10)
    # ```
    def add(range : Range(Int?, Int?), val : T) : T
      left = (range.begin || 0)
      right = if range.end.nil?
          @size + 1
        else
          range.end.not_nil! + (range.exclusive? ? 0 : 1)
        end
      add(left, right, val)
    end
  
    # 添字 i の値を取得します。
    #
    # ```
    # imos = Imos(Int32).new(n)
    # imos.add(0..n, 10)
    # imos.add(0..n // 2, 10)
    # imos.get(0) # => 20
    # imos.get(n) # => 10
    # ```
    def get(i : Int) : T
      build if @should_build
      @sums[i]
    end
  
    # 添字 i の値を取得します。
    #
    # 配列が build 済みかの確認は行いません。
    #
    # ```
    # imos = Imos(Int32).new(n)
    # imos.add(0..n, 10)
    # imos.add(0..n // 2, 10)
    # imos.get(0) # => 20
    # imos.get(n) # => 10
    # ```
    def get!(i : Int) : T
      @sums[i]
    end
  
    # 添字 i の値を取得します。
    #
    # 配列外参照をした場合 nil が返ります。
    #
    # ```
    # imos = Imos(Int32).new(n)
    # imos.add(0..n, 10)
    # imos.add(0..n // 2, 10)
    # imos.get(0) # => 20
    # imos.get(n) # => 10
    # ```
    def get?(i : Int) : T?
      build if @should_build
      @sums[i]?
    end
  
    def each(& : T -> )
      build if @should_build
      @sums.each { |s| yield s }
    end
  
    def [](i : Int) : T; get(i) end
    def []?(i : Int) : T?; get?(i) end
  
    def build
      @sums = @added.dup
      (@size + 1).times do |i|
        @sums[i + 1] += @sums[i]
      end
      @sums.pop
      @should_build = false
    end
  end
end