module NgLib
  # 不定方程式 $ax + by = c$ を解きます。
  #
  # 常に解が存在するわけではないので、`#has_solution?` などで解が存在するかを確かめるようにしてください。
  #
  # 多分、解の媒介変数 $m = 0$ のとき、$|x| + |y|$ が最小になります。
  class LDE(T)
    class NotHasSolutionError < Exception; end

    @a : T
    @b : T
    @c : T

    @check : Bool

    @x0 : T
    @y0 : T
    @a2 : T
    @b2 : T
    @m : T

    # 不定方程式 $ax + by = c$ を作ります。
    def initialize(a, b, c)
      @a, @b, @c = T.new(a), T.new(b), T.new(c)
      @m = T.zero
      x = [T.zero]
      y = [T.zero]

      @check = true
      g = @a.gcd(@b)

      if @c % g != 0
        @x0 = @y0 = @a2 = @b2 = T.zero
        @check = false
      else
        extgcd(@a.abs, @b.abs, x, y)

        x[0] = -x[0] if @a < 0
        y[0] = -y[0] if @b < 0

        x[0] *= @c // g
        y[0] *= @c // g

        @x0 = x[0]
        @y0 = y[0]

        @a2 = -@a // g
        @b2 = @b // g
      end
    end

    # 現在の $m$ の値に対する $x$ の解を返します。
    #
    # 解は媒介変数 $m$ を用いて $x = x_0 + mk,\ y = y_0 + mh$ と求まるので、
    # この $x$ を返します。
    #
    # 解が存在しない場合は `nil` を返します。
    def x : T?
      @check ? @x0 : nil
    end

    # 現在の $m$ の値に対する $x$ の解を返します。
    #
    # 解は媒介変数 $m$ を用いて $x = x_0 + mk,\ y = y_0 + mh$ と求まるので、
    # この $x$ を返します。
    #
    # 解が存在しない場合は例外を送出します。
    def x! : T
      x || raise NotHasSolutionError.new
    end

    # 現在の $m$ の値に対する $y$ の解を返します。
    #
    # 解は媒介変数 $m$ を用いて $x = x_0 + mk,\ y = y_0 + mh$ と求まるので、
    # この $y$ を返します。
    #
    # 解が存在しない場合は `nil` を返します。
    def y : T?
      @check ? @y0 : nil
    end

    # 現在の $m$ の値に対する $y$ の解を返します。
    #
    # 解は媒介変数 $m$ を用いて $x = x_0 + mk,\ y = y_0 + mh$ と求まるので、
    # この $y$ を返します。
    #
    # 解が存在しない場合は例外を送出します。
    def y! : T
      y || raise NotHasSolutionError.new
    end

    # 解は媒介変数 $m$ を用いて $x = x_0 + mk,\ y = y_0 + mh$ と求まるので、
    # この $k$ を返します。
    #
    # 解が存在しない場合は `nil` を返します。
    def k : T?
      @check ? @b2 : nil
    end

    # 現在の $m$ の値に対する $k$ の解を返します。
    #
    # 解は媒介変数 $m$ を用いて $x = x_0 + mk,\ y = y_0 + mh$ と求まるので、
    # この $k$ を返します。
    #
    # 解が存在しない場合は例外を送出します。
    def k! : T
      k || raise NotHasSolutionError.new
    end

    # 解は媒介変数 $m$ を用いて $x = x_0 + mk,\ y = y_0 + mh$ と求まるので、
    # この $h$ を返します。
    #
    # 解が存在しない場合は `nil` を返します。
    def h : T?
      @check ? @a2 : nil
    end

    # 現在の $m$ の値に対する $h$ の解を返します。
    #
    # 解は媒介変数 $m$ を用いて $x = x_0 + mk,\ y = y_0 + mh$ と求まるので、
    # この $h$ を返します。
    #
    # 解が存在しない場合は例外を送出します。
    def h! : T
      h || raise NotHasSolutionError.new
    end

    # 現在の $m$ の値に対する解を返します。
    #
    # 解は媒介変数 $m$ を用いて $x = x_0 + mk,\ y = y_0 + mh$ と求まるので、
    # $(x_0, b', y_0, a')$ をこの順に格納したタプルとして返します。
    #
    # 解が存在しない場合は `nil` を返します。
    def solution : {T, T, T, T}?
      @check ? {@x0, @b2, @y0, @a2} : nil
    end

    # 現在の $m$ の値に対する解を返します。
    #
    # 解が存在しない場合は例外を送出します。
    def solution! : {T, T, T, T}
      solution || raise NotHasSolutionError.new
    end

    # 解が存在するかを返します。
    def has_solution?
      @check
    end

    # 媒介変数 $m$ の値を返します。
    def m
      @m
    end

    # 媒介変数 $m$ の値を更新します。
    def m=(m)
      @x0 += (-(@m - m)) * @b2
      @y0 += (-(@m - m)) * @a2
      @m = T.new(m)
    end

    def to_s(io : IO)
      io << @a << "x" << (@b < 0 ? " - " : " + ") << @b.abs << "y = " << @c << " # => x = " << x << ", y = " << y
    end

    def inspect(io : IO)
      to_s(io)
    end

    private def extgcd(a, b, x, y)
      if b == 0
        x[0], y[0] = T.new(1), T.new(0)
        return a
      end
      d = extgcd(b, a % b, y, x)
      y[0] -= (a // b) * x[0]
      d
    end
  end
end
