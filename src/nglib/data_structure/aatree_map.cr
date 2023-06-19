module NgLib
  # 順序付き連想配列です。
  #
  # 平衡二分探索木として [AA木](https://ja.wikipedia.org/wiki/AA%E6%9C%A8) を使用しています。
  # 性能は赤黒木の方が良いことが多い気がします。
  #
  # C++の標準ライブラリの `multiset` と違って、$k$ 番目の値が取り出せることなどが魅力的です。
  class AATreeMap(K, V)
    include Enumerable({K, V})

    private class Node(K, V)
      property left : Node(K, V)?
      property right : Node(K, V)?
      property parent : Node(K, V)?
      property key : K
      property value : V
      property level : Int32
      property size : Int32

      def initialize(item : {K, V})
        @left = @right = @parent = nil
        @level = 1
        @key = item[0]
        @value = item[1]
        @size = 1
      end

      def rotate_left : Node(K, V)
        right = @right.not_nil!
        mid = right.left
        par = @parent
        if right.parent = par
          if par.not_nil!.left == self
            par.not_nil!.left = right
          else
            par.not_nil!.right = right
          end
        end
        mid.parent = self if @right = mid
        right.left = self
        @parent = right

        sz = @size
        @size += (mid ? mid.size : 0) - right.size
        right.size = sz

        right
      end

      def rotate_right : Node(K, V)
        left = @left.not_nil!
        mid = left.right
        par = @parent

        if left.not_nil!.parent = par
          if par.not_nil!.left == self
            par.not_nil!.left = left
          else
            par.not_nil!.right = left
          end
        end
        mid.parent = self if @left = mid
        left.not_nil!.right = self
        @parent = left

        sz = @size
        @size += (mid ? mid.size : 0) - left.size
        left.size = sz

        left
      end

      def left_side?(node : Node(K, V)?) : Bool
        @left == node
      end

      def assign(node : Node(K, V)) : V
        @key = node.key
        @value = node.value
      end
    end

    @root : Node(K, V)?
    @default : V?

    private def find_node(node : Node(K, V)?, key : K) : Node(K, V)?
      return nil unless node
      until key == node.not_nil!.key
        if key < node.not_nil!.key
          break unless node.not_nil!.left
          node = node.not_nil!.left
        else
          break unless node.not_nil!.right
          node = node.not_nil!.right
        end
      end
      node
    end

    private def skew(node : Node(K, V)?) : Node(K, V)?
      return nil unless node
      left = node.not_nil!.left
      if left && node.not_nil!.level == left.not_nil!.level
        return node.not_nil!.rotate_right
      end
      node
    end

    private def split(node : Node(K, V)?) : Node(K, V)?
      return nil unless node
      right = node.right
      if right && right.not_nil!.right && node.level == right.not_nil!.right.not_nil!.level
        r = node.rotate_left
        r.level += 1
        return r
      end
      node
    end

    private def upsert(key : K, value : V) : Nil
      unless @root
        @root = Node.new({key, value})
        return true
      end

      node = find_node(@root, key)
      if node.not_nil!.key == key
        node.not_nil!.value = value
        return
      end

      new_node = Node.new({key, value})
      if key < node.not_nil!.key
        node.not_nil!.left = new_node
      else
        node.not_nil!.right = new_node
      end
      new_node.not_nil!.parent = node

      node = new_node
      while node
        node = split(skew(node))
        unless node.not_nil!.parent
          @root = node
          break
        end
        node = node.not_nil!.parent
        node.not_nil!.size += 1
      end
    end

    private def begin_node : Node(K, V)?
      return nil unless @root
      node = @root
      while node.not_nil!.left
        node = node.not_nil!.left
      end
      node
    end

    private def next_node(node : Node(K, V)) : Node(K, V)?
      if node.right
        node = node.right
        while node.not_nil!.left
          node = node.not_nil!.left
        end
        node
      else
        while node
          par = node.not_nil!.parent
          if par && par.not_nil!.left_side?(node)
            return par
          end
          node = par
        end
        node
      end
    end

    private def level(node : Node(K, V)?)
      node ? node.level : 0
    end

    def initialize
      @root = nil
      @default = nil
      self
    end

    def initialize(@default : V)
      @root = nil
      self
    end

    def initialize(enumerable : Enumerable({K, V}))
      @root = nil
      concat(enumerable)
      self
    end

    def concat(elems) : self
      elems.each { |elem| self << elem }
      self
    end

    def includes?(key : K, value : V) : Bool
      node = find_node(@root, key)
      node.nil? ? false : node.key == key && node.value == value
    end

    def clear
      @root = nil
    end

    def empty? : Bool
      @root.nil?
    end

    def at(k : Int) : {K, V}
      k += size if k < 0
      raise IndexError.new unless 0 <= k && k < size
      node = @root
      k += 1
      loop do
        left_size = (node.not_nil!.left ? node.not_nil!.left.not_nil!.size : 0) + 1
        break if left_size == k

        if k < left_size
          node = node.not_nil!.left
        else
          node = node.not_nil!.right
          k -= left_size
        end
      end
      {node.not_nil!.key, node.not_nil!.value}
    end

    def at?(k : Int) : {K, V}?
      k += size if k < 0
      return nil unless 0 <= k && k < size
      at(k)
    end

    def key_at(k : Int) : K
      at(k)[0]
    end

    def key_at?(k : Int) : K?
      t = at?(k); t ? t[0] : nil
    end

    def value_at(k : Int) : V
      at(k)[1]
    end

    def value_at?(k : Int) : V?
      t = at?(k); t ? t[1] : nil
    end

    def each_key(& : K ->)
      each do |key, _|
        yield key
      end
    end

    def each_value(& : V ->)
      each do |_, value|
        yield value
      end
    end

    def each(& : {K, V} ->)
      node = begin_node
      while node
        pr = {node.not_nil!.key, node.not_nil!.value}
        yield pr
        node = next_node(node.not_nil!)
      end
    end

    def keys : Array(K)
      res = Array(K).new
      each do |key, _|
        res << key
      end
      res
    end

    def values : Array(V)
      res = Array(V).new
      each do |_, value|
        res << value
      end
      res
    end

    def delete_key(key : K) : Bool
      return false unless @root

      node = find_node(@root, key)
      return false unless node.not_nil!.key == key

      if node.not_nil!.left || node.not_nil!.right
        child = find_node(node.not_nil!.left ? node.not_nil!.left : node.not_nil!.right, key)
        node.not_nil!.assign(child.not_nil!)
        node = child
      end

      par = node.not_nil!.parent
      if par
        if par.not_nil!.left_side?(node)
          par.left = nil
        else
          par.right = nil
        end
      else
        @root = nil
      end
      node = par

      while node
        new_level = {level(node.left), level(node.right)}.min + 1
        if new_level < node.level
          node.level = new_level
          if new_level < level(node.right)
            node.right.not_nil!.level = new_level
          end
        end

        node.size -= 1
        node = skew(node).not_nil!
        skew(node.right.not_nil!.right) if skew(node.right)

        node = split(node)
        split(node.not_nil!.right)

        unless node.not_nil!.parent
          @root = node
          break
        end
        node = node.not_nil!.parent
      end
      true
    end

    # TODO: Improve performance
    def delete_at(k : Int)
      key = key_at(k)
      delete_key(key)
    end

    # TODO: Improve performance
    def delete_at(k : Int)
      key = key_at?(k)
      return if key.nil?
      delete_key(key)
    end

    def has_key?(key : K) : Bool
      return false unless @root
      node = find_node(@root, key)
      node.nil? ? false : node.key == key
    end

    def lower_bound_index(key : K) : Int32
      node = @root
      return 0 unless node
      index = 0
      while node
        if key <= node.not_nil!.key
          node = node.not_nil!.left
        else
          index += (node.not_nil!.left ? node.not_nil!.left.not_nil!.size : 0) + 1
          node = node.not_nil!.right
        end
      end
      index
    end

    def upper_bound_index(key : K) : Int32
      node = @root
      return 0 unless node
      index = 0
      while node
        if key < node.not_nil!.key
          node = node.not_nil!.left
        else
          index += (node.not_nil!.left ? node.not_nil!.left.not_nil!.size : 0) + 1
          node = node.not_nil!.right
        end
      end
      index
    end

    def less_index(key : K) : Int32?
      index = lower_bound_index(key)
      index == 0 ? nil : index - 1
    end

    def less_equal_index(key : K) : Int32?
      index = lower_bound_index(key)
      key == at?(index) ? index : (index == 0 ? nil : index - 1)
    end

    def greater_index(key : K) : Int32?
      index = upper_bound_index(key)
      index == size ? nil : index
    end

    def greater_equal_index(key : K) : Int32?
      index = lower_bound_index(key)
      index == size ? nil : index
    end

    def size : Int32
      @root ? @root.not_nil!.size : 0
    end

    def to_a : Array({K, V})
      res = Array({K, V}).new
      return res unless @root
      dfs = uninitialized Node(K, V) -> Nil
      dfs = ->(node : Node(K, V)) do
        dfs.call(node.left.not_nil!) if node.left
        res << {node.key, node.value}
        dfs.call(node.right.not_nil!) if node.right
        nil
      end
      dfs.call(@root.not_nil!)
      res
    end

    def to_s(io : IO) : Nil
      io << "{" + to_a.map { |key, value| "#{key} => #{value}" }.join(", ") + "}"
    end

    def inspect(io : IO)
      to_s(io)
    end

    def <<(item : {K, V}) : Nil
      upsert(item[0], item[1])
    end

    def [](key : K) : V
      return @default.not_nil! if @root.nil? && !@default.nil?
      raise KeyError.new "Missing key: #{key.inspect}" unless @root
      node = find_node(@root, key)
      return @default.not_nil! if node.not_nil!.key != key && !@default.nil?
      raise KeyError.new "Missing key: #{key.inspect}" if node.not_nil!.key != key
      node.not_nil!.value
    end

    def []?(key : K) : V?
      return @default if @root.nil?
      node = find_node(@root, key)
      return @default if node.not_nil!.key != key
      node.not_nil!.value
    end

    def []=(key : K, value : V) : V
      upsert(key, value)
      value
    end
  end
end
