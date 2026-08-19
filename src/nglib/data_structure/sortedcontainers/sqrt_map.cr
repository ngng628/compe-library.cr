require "./sqrt_set.cr"

module NgLib
  class SqrtMap(K, V)
    include Enumerable({K, V})
    include Iterable({K, V})

    @keys : NgLib::SqrtSet(K)
    @values : Hash(K, V)
    @block : (self, K -> V)?

    delegate size, to: @keys

    def self.new(default_value : V)
      new { default_value }
    end

    def self.new(&block : self, K -> V)
      new block
    end

    def initialize(@block : (self, K -> V)? = nil)
      @keys = NgLib::SqrtSet(K).new
      @values = Hash(K, V).new
    end

    def self.new(hash : Hash(K, V))
      map = self.new
      hash.each do |key, value|
        map[key] = value
      end
      map
    end

    def self.zip(keys : Array(K), values : Array(V))
      map = self.new
      keys.zip(values) do |key, value|
        map[key] = value
      end
      map
    end

    def put(key : K, value : V, &)
      item = upsert(key, value)
      item ? item[1] : yield key
    end

    def [](key : K) : V
      fetch(key) {
        if block = @block
          block.call(self, key)
        else
          raise KeyError.new "Missing hash key: #{key.inspect}"
        end
      }
    end

    def []?(key : K) : V?
      fetch(key, nil)
    end

    def []=(key : K, value : V) : V
      upsert(key, value)
      value
    end

    def fetch(key : K, &)
      has_key?(key) ? @values[key] : yield key
    end

    def fetch(key : K, default_value)
      fetch(key) { default_value }
    end

    def has_key?(key : K) : Bool
      @values.has_key?(key)
    end

    def update(key : K, & : V -> V) : V
      if has_key?(key)
        self[key] = yield self[key]
      elsif block = @block
        default_value = block.call(self, key)
        upsert(key, yield default_value)
        default_value
      else
        raise KeyError.new "Missing hash key: #{key.inspect}"
      end
    end

    def delete(key : K) : V?
      return nil unless has_key?(key)
      @keys.delete(key)
      @values.delete(key)
    end

    def unsafe_fetch(index : Int) : {K, V}
      key = @keys.unsafe_fetch(index)
      {key, @values[key]}
    end

    def fetch_at(index : Int, &)
      index += size if index < 0
      return yield index unless 0 <= index && index < size
      unsafe_fetch(index)
    end

    def fetch_at(index : Int, default_value)
      fetch_at(index) { default_value }
    end

    def at(index : Int) : {K, V}
      fetch_at(index) { raise IndexError.new }
    end

    # Returns the key-value at the *index*-th.
    def at(index : Int, &)
      fetch_at(index) { |i| yield i }
    end

    # Like `at`, but returns `nil`
    # if trying to access an key-value outside the set's range.
    def at?(index : Int) : {K, V}?
      fetch_at(index) { nil }
    end

    # Returns the key at the *index*-th.
    def key_at(index : Int) : K
      ret = fetch_at(index, nil)
      if ret.nil?
        raise IndexError.new
      else
        ret[0]
      end
    end

    # Like `at`, but returns `nil`
    # if trying to access an key outside the set's range.
    def key_at?(index : Int) : K?
      item = at?(index)
      item.try &.[0]
    end

    # Returns the value at the *index*-th.
    def value_at(index : Int) : V
      ret = fetch_at(index, nil)
      if ret.nil?
        raise IndexError.new
      else
        ret[1]
      end
    end

    # Like `at`, but returns `nil`
    # if trying to access an value outside the set's range.
    def value_at?(index : Int) : V?
      item = at?(index)
      item.try &.[1]
    end

    def keys : Array(K)
      map &.[0]
    end

    def values : Array(V)
      map &.[1]
    end

    def values_by_key(*keys : K)
      keys.map { |key| self[key] }
    end

    def values_at(*indices : Int)
      indices.map { |index| value_at(index) }
    end

    def invert : SqrtMap(V, K)
      inverted = SqrtMap(V, K).new
      each do |key, value|
        inverted[value] = key
      end
      inverted
    end

    def key_for(value) : K
      key_for(value) { raise KeyError.new "Missing hash key for value: #{value}" }
    end

    def key_for?(value) : K?
      key_for(value) { nil }
    end

    def key_for(value, &)
      each do |k, v|
        return k if v == value
      end
      yield value
    end

    def each(&) : Nil
      @keys.each do |key|
        yield({key, @values[key]})
      end
    end

    def each : Iterator({K, V})
      @keys.each.map { |key| {key, @values[key]} }
    end

    private def upsert(key : K, value : V) : {K, V}?
      if has_key?(key)
        old_value = @values[key]
        @values[key] = value
        {key, old_value}
      else
        @keys.add(key)
        @values[key] = value
        nil
      end
    end
  end
end
