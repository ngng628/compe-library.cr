# verification-helper: PROBLEM http://onlinejudge.u-aizu.ac.jp/courses/lesson/8/ITP2/7/ITP2_7_C

require "../../src/nglib/data_structure/aatree_set"

q = read_line.to_i

set = NgLib::AATreeSet(Int32).new
ans = String.build { |io|
  q.times do
    t, *query = read_line.split.map &.to_i
    case t
    when 0
      set << query[0]
      io << set.size << '\n'
    when 1
      io << (set.includes?(query[0]) ? 1 : 0) << '\n'
    when 2
      set.delete(query[0])
    when 3
      li = set.greater_equal_index(query[0])
      ri = set.less_equal_index(query[1])
      next if li.nil? || ri.nil?
      (li..ri).each do |i|
        io << set.at(i) << '\n'
      end
    end
  end
}

print(ans)
