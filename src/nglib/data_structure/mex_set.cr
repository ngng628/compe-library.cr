require "./aatree_set"
require "./aatree_multiset"

module NgLib
  class MexSet(T)
    @set : AATreeSet({T, T})
    @mset : AATreeMultiset(T)

    def initialize
      @set = AATreeSet({T, T}).new([
        {T::MIN, T::MIN},
        {T::MAX, T::MAX},
      ])
      @mset = AATreeMultiset(T).new
    end

    # 下限値 `inf` で、上限値が `sup` の `MexSet` を構築します。
    #
    # NOTE: 非推奨の API です。mex を求めるときに `inf` のみ指定する方法を推奨します。
    #
    # ```
    # # 非負整数に対する MexSet
    # set = MexSet(Int64).new(0_i64, Int64::MAX)
    # ```
    def initialize(inf : T, sup : T)
      @set = AATreeSet({T, T}).new([
        {inf, inf},
        {sup, sup},
      ])
      @mset = AATreeMultiset(T).new
    end

    # 集合に $x$ が含まれるなら `true` を返します。
    def includes?(x : T)
      i = @set.greater_equal_index({x.succ, x.succ}).not_nil! - 1
      l, u = @set[i]
      return l <= x && x <= u
    end

    # 集合に $x$ を追加します。
    def add(x : T)
      ni = @set.greater_equal_index({x.succ, x.succ}).not_nil!
      nl, nu = @set[ni]
      i = ni - 1
      l, u = @set[i]

      if l <= x && x <= u
        @mset << x
        return self
      end

      if u == x - 1
        if nl == x + 1
          @set.delete({l, u})
          @set.delete({nl, nu})
          @set << {l, nu}
        else
          @set.delete({l, u})
          @set << {l, x}
        end
      else
        if nl == x + 1
          @set.delete({nl, nu})
          @set << {x, nu}
        else
          @set << {x, x}
        end
      end
      self
    end

    # 集合に $x$ を追加します。
    #
    # mex の値に変更があったとき `true` を返します。
    def add?(x : T)
      ni = @set.greater_equal_index({x.succ, x.succ}).not_nil!
      nl, nu = @set[ni]
      i = ni - 1
      l, u = @set[i]

      if l <= x && x <= u
        @mset << x
        return false
      end

      if u == x - 1
        if nl == x + 1
          @set.delete({l, u})
          @set.delete({nl, nu})
          @s << {l, nu}
        else
          @set.delete({l, u})
          @set << {l, x}
        end
      else
        if nl == x + 1
          @set.delete({nl, nu})
          @set << {x, nu}
        else
          @set << {x, x}
        end
      end
      true
    end

    # 集合から $x$ を削除します。
    def delete(x : T)
      i0 = @mset.greater_equal_index(x)
      if !i0.nil? && @mset[i0] == x
        @mset.delete_at(i0.not_nil!)
        return self
      end
      i = @set.greater_equal_index({x + 1, x + 1}).not_nil! - 1
      l, u = @set[i]
      if x < l || u < x
        return self
      end

      @set.delete_at(i)
      if x == l && l < u
        @set << {l + 1, u}
      elsif x == u && l < u
        @set << {l, u - 1}
      else
        @set << {l, x - 1}
        @set << {x + 1, u}
      end

      return self
    end

    # 集合から $x$ を削除します。
    #
    # 実際に値が削除された場合 `true` を返します。
    def delete?(x : T)
      i0 = @mset.index(x)
      unless i0.nil?
        @mset.delete_at(i0.not_nil!)
        return true
      end
      i = @set.greater_equal_index({x + 1, x + 1}).not_nil! - 1
      l, u = @set[i]
      if x < l || u < x
        return false
      end

      @set.delete_at(i)
      if x == l && l < u
        @set << {l + 1, u}
      elsif x == u && l < u
        @set << {l, u - 1}
      else
        @set << {l, x - 1}
        @set << {x + 1, u}
      end

      return true
    end

    # `inf` を下限値として $\mathrm{mex}$ を求めます。
    #
    # 非負整数に対する $\mathrm{mex}$ はデフォルト値の T.zero を使用すれば良いです。
    def mex(inf : T = T.zero)
      i = @set.greater_equal_index({inf + 1, inf + 1}).not_nil! - 1
      l, u = @set[i]
      if l <= inf && inf <= u
        return u + 1
      end
      inf
    end

    # `add` へのエイリアスです。
    def <<(x : T)
      add(x)
    end
  end
end
