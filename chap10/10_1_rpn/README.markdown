# 10.1 逆ポーランド記法電卓

## 数式の書き方

- 中置記法
    - よく見る数式の書き方。オペランド (変数や数) の間に演算子を置くスタイル。
    - 例:
        - `(1 + 2 + 3) * 10`
- 後置記法、逆ポーランド記法 (Reverse Polish Notation, RPN)
    - 演算子を後ろに書く。Forth や PostScript のスタイル。
    - 例:
        - `1 2 3 + + 10 *`
- 前置記法、ポーランド記法
    - 演算子を頭に書く。Haskell の関数呼び出し。
    - 例:
        - `* + + 1 2 3 10`

## RPN の評価方法

読み込んだトークンが値だったらスタックに積む (push)。トークンが演算子だったら、その演算子が必要な個数の値をスタックから取り出し (pop) 、演算を評価して結果をスタックに積む。

```
                   3     2
                4  4  7  7 14
     Stack: 10 10 10 10 10 10 -4

Expression: 10  4  3  +  2  *  -
```

## RPN 関数を書く (教科書を見ずにやったらこうなった)

`"10 4 3 + 2 * -"` のような文字列を受け取って、結果の数値を返す関数を `evalRPN` という名前で定義しよう。

```haskell
evalRPN :: String -> Double
```

この関数は文字列をトークン列へ変換して、それを次の関数に渡すだけで良い。次の関数とは、受け取ったトークン列を逆ポーランド記法として評価して結果の値を返す関数である。

```haskell
evalRPNTokens :: [String] -> Double
```

トークン列への変換は文字列を空白で区切るだけで良いはずだから、`evalRPN` は次のような定義になるはず。

```haskell
evalRPN = evalRPNTokens . words 
```

次に、`evalRPNTokens` 関数の中身を考える。この関数は、`["10", "4", "3", "+", "2", "*", "-"]` のようなリストを受け取り、これを逆ポーランド記法として評価する。
これは、現在のスタックと次に評価するトークンの2つの引数を与えたときに、トークンが数値か演算子かによって適切にスタックを操作して新しいスタックを返す関数があれば、その関数とトークン列を `fold` することで実現できるだろう。
その関数名は `evalRPNToken` とする。

```haskell
evalRPNToken :: [Double] -> String -> [Double]
```

トークンが演算子である場合は、その演算を実施すれば良い。

```haskell
evalRPNToken (x1:x2:xs) "+" = (x2 + x1):xs
evalRPNToken (x1:x2:xs) "-" = (x2 - x1):xs
evalRPNToken (x1:x2:xs) "*" = (x2 * x1):xs
evalRPNToken (x1:x2:xs) "/" = (x2 / x1):xs
evalRPNToken (x1:x2:xs) "**" = (x2 ** x1):xs
evalRPNToken (x:xs) "exp" = (exp x):xs
evalRPNToken (x:xs) "log" = (log x):xs
evalRPNToken (x:xs) "sin" = (sin x):xs
evalRPNToken (x:xs) "cos" = (cos x):xs
evalRPNToken (x:xs) "tan" = (tan x):xs
evalRPNToken xs "sum" = [sum xs]
evalRPNToken xs "mean" = [(sum xs) / (length xs)]
```

そして、トークンが演算子ではない場合は数値と看做して処理する。

```haskell
evalRPNToken xs s = (read s):xs
```

最後に `evalRPNTokens` の定義を示す。`evalRPNToken` と空のスタックを `fold` して、結果として得られるリストの先頭を返す関数になる。

```haskell
evalRPNTokens = head . (foldl evalRPNToken [])
```

## 実行結果

```
$ ghci
GHCi, version 7.6.3: http://www.haskell.org/ghc/  :? for help
Loading package ghc-prim ... linking ... done.
Loading package integer-gmp ... linking ... done.
Loading package base ... linking ... done.
Prelude> :l rpn.hs
[1 of 1] Compiling Main             ( rpn.hs, interpreted )
Ok, modules loaded: Main.
*Main> evalRPN "10 4 3 + 2 * -"
-4.0
*Main> evalRPN "2 3.5 +"
5.5
*Main> evalRPN "90 34 12 33 55 66 + * - +"
-3947.0
*Main> evalRPN "90 34 12 33 55 66 + * - + -"
4037.0
*Main> evalRPN "10 2 **"
100.0
*Main> evalRPN "30 sin"
-0.9880316240928618
*Main> evalRPN "45 cos"
0.5253219888177297
*Main> evalRPN "45 tan"
1.6197751905438615
*Main> evalRPN "2.718 log"
0.999896315728952
*Main>
```
