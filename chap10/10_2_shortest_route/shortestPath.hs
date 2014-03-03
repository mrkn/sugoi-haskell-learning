import Data.List

data Section = Section { getA :: Int, getB :: Int, getC :: Int } deriving (Show)
type RoadSystem = [Section]

data Segment = A | B | C deriving (Show)
type Path = [(Segment, Int)]

main = do
  contents <- getContents
  let triples = groupsOf 3 (map read $ lines contents)
      sections = map (\[a, b, c] -> Section a b c) triples
      shortestPath = shortestPathForRoadSystem sections
      path = concat $ map (show . fst) shortestPath
      duration = pathDuration shortestPath
  putStrLn $ "shortest path: " ++ path
  putStrLn $ "duration: " ++ show duration

groupsOf :: Int -> [a] -> [[a]]
groupsOf 0 _ = undefined
groupsOf _ [] = []
groupsOf n xs = (take n xs) : (groupsOf n (drop n xs))

shortestPathForRoadSystem :: RoadSystem -> Path
shortestPathForRoadSystem sections =
  if duration1 < duration2
    then reverse path1
    else reverse path2
  where
    (path1, path2) = foldl shortestPathForSection ([], []) sections
    duration1 = pathDuration path1
    duration2 = pathDuration path2

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
                  then (B, b):path2
                  else (C, c):(A, a):path1


pathDuration :: Path -> Int
pathDuration = sum . (map snd)
