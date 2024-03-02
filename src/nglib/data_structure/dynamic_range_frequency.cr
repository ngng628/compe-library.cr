require "./aatree_set.cr"

module NgLib
  # 長さ $n$ の整数列 $a_0, a_1, \cdots, a_{n-1}$ について、
  # $[l, r)$ に $x$ が何回現れるかを $O(\log{N})$ で計算するクラスです。
  class DynamicRangeFrequency(T)
    @size : Int32
    @map : Hash(Int32, NgLib::AATreeSet(Int32))
    @values : Array(T)
  
    def initialize(array : Array(T))
      @values = array.clone
      @size = array.size
      @map = Hash(Int32, NgLib::AATreeSet(Int32)).new
      array.each_with_index do |a, i|
        @map[a] = NgLib::AATreeSet(Int32).new unless @map.has_key?(a)
        @map[a] << i
      end
    end
  
    def count(range : Range(Int?, Int?), x : T)
      left = (range.begin || 0).to_i32
      right = ((range.end || @size) + (range.exclusive? || range.end.nil? ? 0 : 1)).to_i32
      v = @map[x]? || NgLib::AATreeSet(Int32).new
      lower_bound(v, right) - lower_bound(v, left)
    end
  
    def []=(i : Int, x : T)
      @map[@values[i]].delete(i.to_i32)
      @map[x] = NgLib::AATreeSet(Int32).new unless @map.has_key?(x)
      @map[x] << i.to_i32
      @values[i] = x
    end
  
    private def lower_bound(v : NgLib::AATreeSet(Int32), x : Int32)
      v.greater_equal_index(x) || v.size
    end
  end
end
