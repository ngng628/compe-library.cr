# verification-helper: PROBLEM http://onlinejudge.u-aizu.ac.jp/courses/lesson/8/ITP2/7/ITP2_7_D

require "../../src/nglib/data_structure/aatree_multiset"

q = read_line.to_i

set = NgLib::AATreeMultiset(Int32).new
ans = String.build { |io|
  q.times do
    t, *query = read_line.split.map &.to_i
    case t
    when 0
      set << query[0]
      io << set.size << '\n'
    when 1
      io << set.count(query[0]) << '\n'
    when 2
      while set.includes?(query[0])
        set.delete(query[0])
      end
    when 3
      li = set.greater_equal_index(query[0])
      ri = set.less_index(query[1] + 1)
      next if li.nil? || ri.nil?
      (li..ri).each do |i|
        io << set.at(i) << '\n'
      end
    end
  end
}

print(ans)
