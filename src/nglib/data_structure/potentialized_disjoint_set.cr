module NgLib
  # 重み付き DSU (Union-Find) などと呼ばれるデータ構造です。
  #
  # Abel 群を載せることができます。すなわち、次のメソッドが実装されているオブジェクトが載ります。
  # - `#zero`
  # - `+`
  # - `-`
  class PotentializedDisjointSet(Abel)
    @n : Int32
    @parent_or_size : Array(Int32)
    @potentials : Array(Abel)
  
    # 0 頂点 0 辺の無向グラフを作ります。
    #
    # ```
    # ut = PotentializedDisjointSet(Abel).new
    # ```
    def initialize
      @n = 0
      @parent_or_size = Array(Int32).new
      @potentials = Array(Abel).new
    end
  
    # n 頂点 0 辺の無向グラフを作ります。
    #
    # ```
    # n = int
    # ut = PotentializedDisjointSet(Abel).new(n)
    # ```
    def initialize(size : Int)
      @n = size.to_i32
      @parent_or_size = [-1] * size
      @potentials = Array.new(size){ Abel.zero }
    end
  
    # w[high] - w[low] = diff となるように、
    # 頂点 low と頂点 high を接続します。
    #
    # （w[low] + diff = w[high] と捉えても良いです。） 
    #
    # 接続後のリーダーを返します。
    #
    # diff は符号付きであることに注意してください。
    # また、low と high がすでに接続されている場合の動作は未定義です。
    #
    # ```
    # n = int
    # ut = PotentializedDisjointSet(Abel).new(n)
    # ut.unite(low: a, high: b, diff: w) # => leader(a) or leader(b)
    # ```
    def unite(low : Int, high : Int, diff : Abel) : Int64
      diff += weight(low) - weight(high)
      x = leader(low)
      y = leader(high)
      return x.to_i64 if x == y
      if -@parent_or_size[x] < -@parent_or_size[y]
        x, y = y, x
        diff = -diff
      end
      @parent_or_size[x] += @parent_or_size[y]
      @parent_or_size[y] = x.to_i32
      @potentials[y] = diff
      x.to_i64
    end
  
    # 頂点 a と頂点 b が同じ連結成分に属しているなら `true` を返します。
    #
    # ```
    # n = int
    # ut = PotentializedDisjointSet(Abel).new(n)
    # ut.equiv?(u, v) # => true
    # ```
    def equiv?(a : Int, b : Int) : Bool
      leader(a) == leader(b)
    end
  
    # 頂点 a の属する連結成分のリーダーを返します。
    #
    # ```
    # n = int
    # ut = PotentializedDisjointSet(Abel).new(n)
    # ut.unite(2, 3, 0)
    # ut.leader(0) # => 0
    # ut.leader(3) # => 2  (3 の可能性もある)
    # ```
    def leader(a : Int) : Int64
      return a.to_i64 if @parent_or_size[a] < 0
      l = leader(@parent_or_size[a]).to_i32
      @potentials[a] += @potentials[@parent_or_size[a]]
      @parent_or_size[a] = l
      @parent_or_size[a].to_i64
    end
  
    # w[high] - w[low] を返します。
    #
    # low と high が同じ連結成分に属していない場合 Abel.zero を返します。
    #
    # ```
    # ut = PotentializedDisjointSet(Abel).new(size: 10)
    # ut.unite(2, 1, 1)
    # ut.unite(2, 3, 5)
    # ut.unite(3, 4, 2)
    # ut.diff(1, 2) # => -1
    # ut.diff(2, 1) # => 1
    # ut.diff(2, 3) # => 5
    # ut.diff(2, 4) # => 7
    # ut.diff(0, 9) # => Abel.zero
    # ```
    def diff(low : Int, high : Int) : Abel
      weight(high) - weight(low)
    end
  
    # w[high] - w[low] を返します。
    #
    # low と high が同じ連結成分に属していない場合 nil を返します。
    #
    # ```
    # ut = PotentializedDisjointSet(Abel).new(size: 10)
    # ut.unite(2, 1, 1)
    # ut.unite(2, 3, 5)
    # ut.unite(3, 4, 2)
    # ut.diff(1, 2) # => -1
    # ut.diff(2, 1) # => 1
    # ut.diff(2, 3) # => 5
    # ut.diff(2, 4) # => 7
    # ut.diff(0, 9) # => nil
    # ```
    def diff?(low : Int, high : Int) : Abel?
      return nil unless equiv?(low, high)
      weight(high) - weight(low)
    end
  
    # 頂点 a が属する連結成分の大きさを返します。
    def size(a : Int) : Int64
      -@parent_or_size[leader(a)].to_i64
    end
  
    # グラフを連結成分に分け、その情報を返します。
    #
    # 返り値は「「一つの連結成分の頂点番号のリスト」のリスト」です。
    # （内側外側限らず）Array 内でどの順番で頂点が格納されているかは未定義です。
    def groups : Array(Array(Int64)) | Nil
      leader_buf = Array(Int64).new(@n, 0_i64)
      group_size = Array(Int64).new(@n, 0_i64)
      @n.times do |i|
        leader_buf[i] = leader(i)
        group_size[leader_buf[i]] += 1
      end
      res = Array.new(@n){ Array(Int64).new() }
      @n.times do |i|
        res[leader_buf[i]] << i.to_i64
      end
      res.delete([] of Int64)
      res
    end
  
    private def weight(a : Int) : Abel
      leader(a)
      @potentials[a]
    end
  end
end