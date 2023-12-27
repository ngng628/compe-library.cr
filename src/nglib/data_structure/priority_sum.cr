require "./aatree_multiset"

module NgLib
  # 昇順（降順） $k$ 個の総和を効率良く求めるためのデータ構造です。
  #
  # 値の追加、削除、$k$ の変更ができます。
  class PrioritySum(T)
    getter k : Int32
    getter sum : T

    @tag : Symbol
    @mset : NgLib::AATreeMultiset(T)
    delegate size, to: @mset
    delegate empty?, to: @mset

    # 下位 $k$ 要素の総和を求めるためのデータ構造を構築します。
    def self.min(k : Int, initial : T = T.zero)
      self.new(:min, k, initial)
    end

    # 上位 $k$ 要素の総和を求めるためのデータ構造を構築します。
    def self.max(k : Int, initial : T = T.zero)
      self.new(:max, k, initial)
    end

    def initialize(@tag : Symbol, k : Int, initial : T = T.zero)
      @k = k.to_i32
      @sum = initial
      @mset = NgLib::AATreeMultiset(T).new
    end

    # 要素 $x$ をデータ構造に追加します。
    #
    # 計算量は $O(\log{n})$ です。
    def add(x : T)
      if size < @k
        @sum += x
      else
        kth = @mset.at(kth_index(@k - 1))
        @sum = @sum - kth + x if cmp(x, kth)
      end
      @mset << x
    end

    # Alias for `#add`
    def <<(x : T)
      add(x)
    end

    # 要素 $x$ をデータ構造から削除します。
    #
    # 計算量は $O(\log{n})$ です。
    def delete(x : T)
      if size <= @k
        @sum -= x
        @mset.delete(x)
      else
        kth = @mset.at(kth_index(@k))
        @sum -= x if cmp(x, kth)
        @mset.delete(x)

        kth2 = @mset.at(kth_index(@k - 1))
        @sum += kth2 if cmp(x, kth)
      end
    end

    # $k$ の値を変更します。
    #
    # 計算量は $\Delta k \log{\Delta k}$
    def k=(k : Int)
      if @k < k
        (k - @k).times do |i|
          break if k + i >= size
          @sum += @mset.at(kth_index(k + i))
        end
      elsif @k > k
        (@k - k).times do |i|
          next if @k - i - 1 >= size
          break if @k - i < 1
          @sum -= @mset.at(kth_index(@k - i - 1))
        end
      end
      @k = k.to_i32
    end

    private def kth_index(k : Int)
      case @tag
      when :max
        @mset.size - k - 1
      when :min
        k
      else
        raise IndexError.new
      end
    end

    private def cmp(a : T, b : T)
      case @tag
      when :max
        a > b
      when :min
        a < b
      end
    end
  end
end
