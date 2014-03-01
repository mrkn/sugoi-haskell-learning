evalRPN :: String -> Double
evalRPN = evalRPNTokens . words

evalRPNTokens :: [String] -> Double
evalRPNTokens = head . (foldl evalRPNToken [])

evalRPNToken :: [Double] -> String -> [Double]
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
evalRPNToken xs "mean" = [(sum xs) / (fromIntegral $ length xs)]
evalRPNToken xs s = (read s):xs
