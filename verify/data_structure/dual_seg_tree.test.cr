# verification-helper: PROBLEM https://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DSL_2_E

require "../../src/nglib/data_structure/dual_seg_tree"

n, q = read_line.split.map &.to_i64
seg = NgLib::DualSegTree.range_add([0_i64] * n)
puts String.build { |io|
  q.times do
    t, *line = read_line.split.map &.to_i64
    case t
    when 0
      s, t, x = line
      s -= 1
      t -= 1
      seg[s..t] = x
    when 1
      i = line[0] - 1
      io << seg[i] << '\n'
    end
  end
}
