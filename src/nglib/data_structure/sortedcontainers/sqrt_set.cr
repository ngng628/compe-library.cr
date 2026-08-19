module NgLib
  class SqrtSet(T)
    include Enumerable(T)
    include Indexable(T)
    include Indexable::Mutable(T)

    BUCKET_RATIO = 16
    SPLIT_RATIO  = 24

    @values : Array(Array(T))
    getter size : Int32

    def initialize
      @values = Array(Array(T)).new
      @size = 0
    end

    def initialize(enumerable : Enumerable(T))
      a = enumerable.to_a
      n = enumerable.size
      if (0...n - 1).any? { |i| a[i] > a[i + 1] }
        a.sort!
      end
      if (0...n - 1).any? { |i| a[i] >= a[i + 1] }
        a, b = [] of T, a
        b.each do |x|
          if a.empty? || a.last != x
            a << x
          end
        end
      end
      n = @size = a.size
      n_buckets = (Math.sqrt(n / BUCKET_RATIO)).ceil.to_i
      @values = Array.new(n_buckets) { |i| a[n.to_i64 * i // n_buckets...n.to_i64 * (i + 1) // n_buckets] }
    end

    def unsafe_fetch(index : Int)
      @values.each do |e|
        if index < e.size
          return e.unsafe_fetch(index)
        end
        index -= e.size
      end
      raise IndexError.new
    end

    def unsafe_put(index : Int, value : T)
      @values.each do |e|
        if index < e.size
          return e.unsafe_put(index, value)
        end
        index -= e.size
      end
      value
    end

    def at(index : Int)
      fetch(index) { raise IndexError.new }
    end

    def at(index : Int, &)
      fetch(index) { |i| yield i }
    end

    def at?(index : Int)
      fetch(index) { nil }
    end

    def min
      first
    end

    def min?
      first?
    end

    def max
      last
    end

    def max?
      last?
    end

    def index(object)
      ans = 0
      @values.each do |e|
        if e.last >= object
          i = e.bsearch_index { |x| x >= object } || e.size
          return e[i] == object ? ans + i : nil
        end
        ans += e.size
      end
      nil
    end

    def index!(object)
      index(object) || raise Enumerable::NotFoundError.new
    end

    def rindex(object)
      ans = 0
      @values.each do |e|
        if e.last >= object
          i = (e.bsearch_index { |x| x > object } || e.size) - 1
          return e[i] == object ? ans + i : nil
        end
        ans += e.size
      end
      nil
    end

    def rindex!(object)
      rindex(object) || raise Enumerable::NotFoundError.new
    end

    def count(object)
      includes?(object) ? 1 : 0
    end

    def count(range : Range(T?, T?))
      b, e = range.begin, range.end
      left = b ? lower_bound_index(b) : 0
      right = if e.nil?
                @size
              else
                if range.exclusive?
                  lower_bound_index(e)
                else
                  upper_bound_index(e)
                end
              end

      right - left
    end

    def upper_bound(object : T)
      @values.each do |e|
        if e.last > object
          return e.bsearch { |x| x > object }
        end
      end
      nil
    end

    def lower_bound(object : T)
      @values.each do |e|
        if e.last >= object
          return e.bsearch { |x| x >= object }
        end
      end
      nil
    end

    def largest_less_than(object)
      @values.reverse_each do |e|
        if e.first < object
          i = e.bsearch_index { |x| x >= object } || e.size
          return e[i - 1]
        end
      end
      nil
    end

    def largest_less_than_or_equal_to(object)
      @values.reverse_each do |e|
        if e.first <= object
          i = e.bsearch_index { |x| x > object } || e.size
          return e[i - 1]
        end
      end
      nil
    end

    def smallest_greater_than(object)
      upper_bound(object)
    end

    def smallest_greater_than_or_equal_to(object)
      lower_bound(object)
    end

    def >(other)
      smallest_greater_than(other)
    end

    def >=(other)
      smallest_greater_than_or_equal_to(other)
    end

    def <(other)
      largest_less_than(other)
    end

    def <=(other)
      largest_less_than_or_equal_to(other)
    end

    def each(& : T ->) : Nil
      @values.each do |e|
        e.each do |x|
          yield x
        end
      end
    end

    def includes?(elem : T)
      return false if @size == 0
      a, _, i = find(elem)
      i != a.size && a[i] == elem
    end

    def add(elem : T) : self
      self << elem
    end

    def add?(elem : T) : Bool
      if size == 0
        @values = [[elem]]
        @size = 1
        return true
      end

      a, b, i = find(elem)
      return false if i != a.size && a[i] == elem
      a.insert(i, elem)
      @size += 1

      if a.size > @values.size * SPLIT_RATIO
        mid = a.size >> 1
        @values[b...b + 1] = [a[...mid], a[mid...]]
      end

      true
    end

    def concat(elems)
      elems.each { |elem| self << elem }
      self
    end

    def <<(elem : T) : self
      if size == 0
        @values = [[elem]]
        @size = 1
        return self
      end

      a, b, i = find(elem)
      return self if i != a.size && a[i] == elem
      a.insert(i, elem)
      @size += 1

      if a.size > @values.size * SPLIT_RATIO
        mid = a.size >> 1
        @values[b...b + 1] = [a[...mid], a[mid...]]
      end

      self
    end

    def delete(object) : self
      return self if @size == 0
      a, b, i = find(object)
      return self if i == a.size || a[i] != object
      pop_impl(a, b, i)
      self
    end

    def delete_at(index : Int, &)
      index += @size if index < 0
      return yield index if index < 0
      @values.each_with_index do |e, i|
        if index < e.size
          return pop_impl(e, i, index)
        end
        index -= e.size
      end
      yield index
    end

    def shift : T
      shift { raise IndexError.new }
    end

    def shift(&)
      delete_at(0) { yield }
    end

    def shift? : T?
      shift { nil }
    end

    def pop(&)
      delete_at(@size - 1) { yield }
    end

    def pop
      pop { raise IndexError.new }
    end

    def pop?
      pop { nil }
    end

    def clear
      @values.clear
      @size = 0
    end

    def empty?
      @size == 0
    end

    def &(other : self) : self
      smaller, larger = size <= other.size ? {self, other} : {other, self}
      set = SqrtSet(T).new
      smaller.each do |object|
        set << object if larger.includes?(object)
      end
      set
    end

    def |(other : SqrtSet(U)) : SqrtSet(T | U) forall U
      set = SqrtSet(T | U).new
      each { |object| set << object }
      other.each { |object| set << object }
      set
    end

    def +(other : SqrtSet(U)) : SqrtSet(T | U) forall U
      self | other
    end

    def -(other : SqrtSet)
      set = SqrtSet(T).new
      each do |value|
        set << value unless other.includes?(value)
      end
      set
    end

    def -(other : Enumerable)
      clone.subtract other
    end

    def ^(other : Enumerable(U)) forall U
      set = SqrtSet(T | U).new(self)
      other.each do |value|
        if includes?(value)
          set.delete value
        else
          set << value
        end
      end
      set
    end

    def subtract(other : Enumerable)
      other.each do |value|
        delete value
      end
      self
    end

    def ===(other : T)
      includes? other
    end

    def intersects?(other)
      if size < other.size
        any? { |object| other.includes?(object) }
      else
        other.any? { |object| includes?(object) }
      end
    end

    def subset_of?(other)
      return false if other.size < size
      all? { |value| other.includes?(value) }
    end

    def proper_subset_of?(other)
      return false if other.size <= size
      all? { |value| other.includes?(value) }
    end

    def superset_of?(other)
      other.subset_of?(self)
    end

    def proper_superset_of?(other)
      other.proper_subset_of?(self)
    end

    def dup
      set = SqrtSet(T).new
      each { |object| set << object }
      set
    end

    def clone
      set = SqrtSet(T).new
      each { |object| set << object }
      set
    end

    def to_a
      @values.flatten
    end

    def inspect(io : IO)
      to_s(io)
    end

    def to_s(io : IO)
      io << "SqrtSet{"
      join io, ", ", &.inspect(io)
      io << '}'
    end

    private def lower_bound_index(object : T) : Int32
      ans = 0
      @values.each do |e|
        if e.last >= object
          return ans + (e.bsearch_index { |x| x >= object } || e.size)
        end
        ans += e.size
      end
      ans
    end

    private def upper_bound_index(object : T) : Int32
      ans = 0
      @values.each do |e|
        if e.last > object
          return ans + (e.bsearch_index { |x| x > object } || e.size)
        end
        ans += e.size
      end
      ans
    end

    private def find(elem : T)
      @values.each_with_index do |e, i|
        if elem <= e.last
          return {e, i, e.bsearch_index { |x| x >= elem } || e.size}
        end
      end
      e = @values[-1]
      i = @values.size - 1
      return {e, i, e.bsearch_index { |x| x >= elem } || e.size}
    end

    private def pop_impl(a, b, i)
      ans = a.delete_at(i)
      @size -= 1
      if a.empty?
        @values.delete_at(b)
      end
      ans
    end
  end
end
