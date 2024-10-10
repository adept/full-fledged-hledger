#!/usr/bin/env stack
-- stack --resolver lts-22.37 script --package shake --package directory --package process --optimize
import Development.Shake
import Development.Shake.FilePath
import Development.Shake.Util
import Data.List
import Text.Printf
import Control.Monad
import System.Console.GetOpt
import System.IO
import System.Directory as D
import System.Process as P

--
-- Hardcoded defaults, overridable via commandline options:
-- 1. Range of years to produce reports for. You would
--    typically want all the years  you have data for.
-- 2. Location of your journal files (path, relative to your export directory)
-- 3. Name of the hledger binary
-- 4. Which accounts to include into opening/closing balances
--
defaultFirstYear     = 2014 :: Int
defaultCurrentYear   = 2017
defaultBaseDir       = ".."
defaultHledgerBinary = "hledger"
defaultEquityQuery   = "assets|liabilities|debts"
--
-- Input file naming scheme
--
input base year = base </> (year ++ ".journal")

--
-- Output file naming scheme.
-- It assumes that you do not have similarly-named journals anywhere among files included
-- from you yearly journals
--
transactions      y = y++"-all.journal"
income_expenses   y = y++"-income-expenses.txt"
balance_sheet     y = y++"-balance-sheet.txt"
cash_flow         y = y++"-cash-flow.txt"
closing_balances  y = y++"-closing.journal"
opening_balances  y = y++"-opening.journal"

--
-- Defining the full set of reports and journals to be generated
--
reports first current =
  concat [ [ transactions         (show y) | y <- all_years ]
         , [ income_expenses      (show y) | y <- all_years ]
         , [ balance_sheet        (show y) | y <- all_years ]
         , [ cash_flow            (show y) | y <- all_years ]
         , [ opening_balances     (show y) | y <- all_years, y/=first ]
         , [ closing_balances     (show y) | y <- all_years, y/=current ]
         ]
  where
    all_years=[first..current]

-----------------------------------------
-- Extra dependencies of the import files
-----------------------------------------
extraDeps file
  | "//lloyds//*.journal" ?== file   = ["lloyds.rules"]
  | otherwise = []

-----------------------------------------------
-- Extra inputs to be fed to conversion scripts
-----------------------------------------------
extraInputs file = []

--
-- Command line flags
--
data Flags =
  Flags { firstYear     :: Int
        , currentYear   :: Int
        , baseDir       :: String
        , hledgerBinary :: String
        , equityQuery   :: String
        } deriving Eq

setFirstYear y flags   = flags{firstYear = read y}
setCurrentYear y flags = flags{currentYear = read y}
setBaseDir d flags     = flags{baseDir = d}
setBinary b flags      = flags{hledgerBinary = b}
setEquityQuery q flags = flags{equityQuery = q}

flags =
  [ Option "" ["first"] (ReqArg (Right . setFirstYear) "YEAR") ("Override current year. Defaults to " ++ show defaultFirstYear)
  , Option "" ["current"] (ReqArg (Right . setCurrentYear) "YEAR") ("Override current year. Defaults to " ++ show defaultCurrentYear)
  , Option "" ["base"] (ReqArg (Right . setBaseDir) "DIR") ("Override the relative location of journal files. Defaults to " ++ show defaultBaseDir)
  , Option "" ["hledger"] (ReqArg (Right . setBinary) "PATH") ("Use this hledger executable. Defaults to " ++ show defaultHledgerBinary)
  , Option "" ["equity"] (ReqArg (Right . setEquityQuery) "QUERY") ("Use this query string to generate opening-closing balances. Defaults to " ++ show defaultEquityQuery)
  ]

main = do
  let defaults = Flags { firstYear = defaultFirstYear, currentYear = defaultCurrentYear, baseDir = defaultBaseDir, hledgerBinary = defaultHledgerBinary, equityQuery = defaultEquityQuery }
  shakeArgsAccumulate shakeOptions flags defaults export_all

-- Build rules
export_all flags targets = return $ Just $ do
  let first = firstYear flags
      current = currentYear flags

  if null targets then want (reports first current) else want targets

  -- Discover and cache the list of all includes for the given .journal file, recursively
  year_inputs <- newCache $ \year -> do
    let file = input (baseDir flags) year
    getIncludes (baseDir flags) file -- file itself will be included here

  liftIO $ (flip mapM_) [first..current] $ \year -> do
    let file = input (baseDir flags) $ show year
    includes <- filter dyngen <$> getIncludes (baseDir flags) file
    (flip mapM_) includes $ \dynfile -> do
      exists <- D.doesFileExist dynfile
      when (not exists) $ do
        putStrLn $ "touching missing dynamic dependency " ++ dynfile
        callProcess "touch" [dynfile,"-r",file]

  (transactions "//*") %> hledger_process_year flags year_inputs ["print"]

  (income_expenses "//*") %> hledger_process_year flags year_inputs ["is","--flat","--no-elide"]

  (balance_sheet "//*") %> hledger_process_year flags year_inputs ["balancesheet","--no-elide"]

  (cash_flow "//*") %> hledger_process_year flags year_inputs ["cashflow","not:desc:(opening balances)","--no-elide"]

  (closing_balances "//*") %> generate_closing_balances flags year_inputs

  (opening_balances "//*") %> generate_opening_balances flags year_inputs

  -- Enumerate directories with auto-generated cleaned csv files
  [ "//import/lloyds/csv/*.csv" ] |%> in2csv

  -- Enumerate directories with auto-generated journals
  [ "//import/lloyds/journal/*.journal" ] |%> csv2journal

-------------------------------------
-- Implementations of the build rules
-------------------------------------

-- Run hledger command on a given yearly file. Year is extracted from output file name.
-- To generate '2017-balances', we will process '2017.journal'
hledger_process_year flags year_inputs args out = do
  let year = head $ split out
  deps <- year_inputs year
  need deps
  (Stdout output) <- cmd (hledgerBinary flags) ("-f" : input (baseDir flags) year : args)
  writeFileChanged out output

generate_opening_balances flags year_inputs out = do
  let year = head $ split out
  let prev_year = show ((read year)-1)
  deps <- year_inputs prev_year
  need deps
  (Stdout output) <-
    cmd (hledgerBinary flags)
    ["-f",input (baseDir flags) prev_year,"equity",equityQuery flags,"-e",year,"--opening"]
  writeFileChanged out output

generate_closing_balances flags year_inputs out = do
  let year = head $ split out
  hledger_process_year flags year_inputs ["equity",equityQuery flags,"-e",show (1+(read year)),"-I","--closing"] out

-- To produce <importdir>/csv/filename.csv, look for <importdir>/in/filename.csv and
-- process it with <importdir>/in2csv
in2csv out = do
  let (csv_dir, file) = splitFileName out
  let source_dir = parentOf "csv" csv_dir
  let in_dir = replaceDir "csv" "in" csv_dir
  possibleInputs <- getDirectoryFiles in_dir [file -<.> "*"]
  let inputs =
        case possibleInputs of
          [] -> error $ "no inputs for " ++ show file
          _ -> map (in_dir</>) $ possibleInputs ++ (extraInputs file)
  let deps = map (source_dir </>) $ extraDeps out
  need $ (source_dir </> "in2csv"):(inputs ++ deps)
  (Stdout output) <- cmd (Cwd source_dir) Shell "./in2csv" (map (makeRelative source_dir) inputs)
  writeFileChanged out output

-- To produce <importdir>/journal/filename.journal, look for <importdir>/csv/filename.csv and
-- process it with <importdir>/csv2journal
csv2journal out = do
  let (journal_dir, file) = splitFileName out
  let source_dir = parentOf "journal" journal_dir
  let csv_dir = replaceDir "journal" "csv" journal_dir
  let input = csv_dir </> (file -<.> "csv")
  let deps = map (source_dir </>) $ extraDeps out
  need $ (source_dir </> "csv2journal"):(input:deps)
  (Stdout output) <- cmd (Cwd source_dir) Shell "./csv2journal" [makeRelative source_dir input]
  writeFileChanged out output

-------------------
-- Helper functions
-------------------

dyngen file = False

-- To get included files, look for 'include' or '!include'. Note that we can't use "hledger files", as
-- some of the requested includes might be generated and might not exist yet.
getIncludes base file = do
  src <- liftIO $ readFile file
  let includes = [normalisePath base x | x <- lines src, Just x <- [ stripPrefix "!include " x
                                                                   , stripPrefix "include " x]]
  return (file:includes)

normalisePath base x
  | "/" `isPrefixOf` x = x
  | "./export/" `isPrefixOf` x, Just y <- stripPrefix "./export/" x = y
  | otherwise = base </> x

split s = takeWhile (/="") $ unfoldr (Just . head . lex) $ takeFileName s

-- Take "dirpath" and return parent dir of "subdir" component
parentOf :: FilePath -> FilePath -> FilePath
parentOf subdir dirpath =
  joinPath $ takeWhile (/= subdir) $ splitDirectories dirpath

-- Take "dirpath" and replace "this" dir component with "that" dir component
replaceDir :: FilePath -> FilePath -> FilePath -> FilePath
replaceDir this that dirpath =
  joinPath $ map (\subdir -> if subdir == this then that else subdir) $ splitDirectories dirpath
