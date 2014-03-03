# 10.2 ヒースロー空港からロンドンへ

## 問題

以下のような重みつきグラフで、A または B を開始点とし G を終点とするとき、最短経路を求めなさい。

```
A --(50)--*---(5)--*--(40)--*--(10)---*-- G
          |        |        |         |
         (30)     (20)     (25)      (0)
          |        |        |         |
B --(10)--*--(90)--*---(2)--*---(8)---*
```

入力データは以下のように与えられるものとする:

```
50
10
30
5
90
20
40
2
25
10
8
0
```

## 入力データの構造

重み付きグラフは以下のように一般化できる。

```
          A1       A2        A_(n-1)    A_n
A --(x1)--*--(x2)--*---...---*--(x_n)---*-- G
          |        |         |          |
        (z1)     (z2)     (z_(n-1))    (0)
          |        |         |          |
B --(y1)--*--(y2)--*---...---*--(y_n)---*
          B1       B2        B_(n-1)    B_n
```

このとき、入力データは次のように構成されている。

```
x1
y1
z1
x2
y2
z2
 :
 :
z_(n-1)
x_n
y_n
0
```

## 入力データの表現

入力データは x, y, z の各重みを持つ3行単位のブロックになっている。それを以下のような複合データで表現する (教科書に合わせて、x, y, z をそれぞれ A, B, C と書くことにする)。

```haskell
data Section = Section { getA :: Int, getB :: Int, getC :: Int } deriving (Show)
type RoadSystem = [Section]
```

## 解き方

最短経路を求める場合は通常 Warshall-Floyd 法や Dijkstra 法を使うが、今回はグラフ構造が規則的なのでもっと簡単な方法で解ける。

グラフのゴールの部分に注目しよう。

```
                   A_n
A_(n-1) *--(x_n)---*-- G
                   |
               (z_n = 0)
                   |
B_(n-1) *--(y_n)---*
                   B_n
```

最短経路を求める最終段階では、 `A_(n-1)` と `B_(n-1)` のそれぞれについての最短経路と到達時間が分かっていると仮定し、`A_(n-1)` または `B_(n-1)` のどちらかから `G` への最短経路を求めることになる。

引数として、`A` および `B` までの経路と1ブロック分の経路情報が与えられたときの最短経路問題を解く関数 `shortestPathForSection` は次のように定義できる。

```haskell
data Segment = A | B | C deriving (Show)
type Path = [(Segment, Int)]

shortestPathForSection :: (Path, Path) -> Section -> (Path, Path)
shortestPathForSection (path1, path2) (Section a b c) = (path_to_a, path_to_b)
  where
    duration1 = (pathDuration path1)
    duration2 = (pathDuration path2)
    from_a_to_a = duration1 + a
    from_a_to_b = duration1 + a + c
    from_b_to_b = duration1 + b
    from_b_to_a = duration1 + b + c
    path_to_a = if from_a_to_a < from_b_to_a
                  then (A, a):path1
                  else (C, c):(B, b):path2
    path_to_b = if from_b_to_b < from_a_to_b
                  then (B, b):path1
                  else (C, c):(A, a):path1
```

ここで `pathDuration` 関数は以下で定義される。

```haskell
pathDuration :: Path -> Int
pathDuration = sum $ map snd
```

そして、`Section` のリストに対して `shortestPathForSection` を fold し、A と B で短いほうを選択する関数を作れば良い。

```haskell
shortestPathForRoadSystem :: RoadSystem -> Path
shortestPathForRoadSystem sections =
  if duration1 < duration2
    then reverse path1
    else reverse path2
  where
    (path1, path2) = foldl shortestPathForSection ([], []) sections
    duration1 = pathDuration path1
    duration2 = pathDuration path2
```

