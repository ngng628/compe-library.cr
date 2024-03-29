module NgLib
  # 長さ $n$ の整数列 $a_0, a_1, \cdots, a_{n-1}$ について、
  # $[l, r)$ に $x$ が何回現れるかを $O(\log{N})$ で計算するクラスです。
  class StaticRangeFrequency(T)
    @size : Int32
    @map : Hash(T, Array(Int32))

    def initialize(array : Array(T))
      @size = array.size
      @map = Hash(T, Array(Int32)).new
      array.each_with_index do |elem, i|
        @map[elem] = [] of Int32 unless @map.has_key?(elem)
        @map[elem] << i
      end
    end

    def query(range : Range(Int?, Int?), x : T)
      left = (range.begin || 0).to_i32
      right = ((range.end || @size) + (range.exclusive? || range.end.nil? ? 0 : 1)).to_i32
      v = @map.fetch(x, [] of Int32)
      lower_bound(v, right) - lower_bound(v, left)
    end

    private def lower_bound(v : Array(Int32), x : Int32)
      v.bsearch_index { |elem| elem >= x } || v.size
    end
  end
end
