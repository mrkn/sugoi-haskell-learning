evalRPN :: String -> Double
evalRPN = evalRPNTokens . words

evalRPNTokens :: [String] -> Double
evalRPNTokens = head . (foldl evalRPNToken [])

evalRPNToken :: [Double] -> String -> [Double]
evalRPNToken = f
  where
    f (x1:x2:xs) "+" = (x2 + x1):xs
    f (x1:x2:xs) "-" = (x2 - x1):xs
    f (x1:x2:xs) "*" = (x2 * x1):xs
    f (x1:x2:xs) "/" = (x2 / x1):xs
    f (x1:x2:xs) "**" = (x2 ** x1):xs
    f (x:xs) "exp" = (exp x):xs
    f (x:xs) "log" = (log x):xs
    f (x:xs) "sin" = (sin x):xs
    f (x:xs) "cos" = (cos x):xs
    f (x:xs) "tan" = (tan x):xs
    f xs "sum" = [sum xs]
    f xs "mean" = [(sum xs) / (fromIntegral $ length xs)]
    f xs s = (read s):xs
