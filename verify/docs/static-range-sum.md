---
title: Static Range Sum (一次元累積和)
documentation_of: //../src/nglib/cumulative-sum.hpp
---

## 概要
数列 $a$ について、$l$ から $r - 1$ までの総和 $\sum_{i=l}^{r-1} a_i$ を $O(1)$ で求めます。


## 使い方

```
a = 1.upto(10).to_a
csum = NgLib::StaticRangeSum.new(a)
csum[0..3] # => 1 + 2 + 3 + 4 = 10
csum[0...3] # => 1 + 2 + 3 = 6
```

## 計算量

- 前計算 $O(N)$
- 総和クエリ $O(1)$
