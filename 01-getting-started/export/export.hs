#!/usr/bin/env stack
-- stack --resolver lts-13.8 runghc --package shake --package directory
import Development.Shake
import Development.Shake.FilePath
import Data.List
import Text.Printf
import Control.Monad
import System.IO
import System.Directory as D

--
-- Range of years to report. You would typically want all the years you have data for.
--
first   = 2017 :: Int
current = 2017
all_years=[first..current]

--
-- Input file naming scheme
--
input y = printf "../%s.journal" y

--
-- File naming scheme
-- It assumes that you do not have similarly-named journals anywhere among files !included
-- from you yearly journals
--
transactions      y = y++"-all.journal"
income_expenses   y = y++"-income-expenses.txt"
balance_sheet     y = y++"-balance-sheet.txt"
cash_flow         y = y++"-cash-flow.txt"
accounts          y = y++"-accounts.txt"
unknown           y = y++"-unknown.journal"
-- which accounts to include in opening/closing reports
open_close_account_query = "assets|liabilities|debts"
closing_balances  y = y++"-closing.journal"
opening_balances  y = y++"-opening.journal"

--
-- Defining the full set of reports and journals to be generated
--
reports =
  concat [ [ transactions         (show y) | y <- all_years ]
         , [ accounts             (show y) | y <- all_years ]
         , [ income_expenses      (show y) | y <- all_years ]
         , [ balance_sheet        (show y) | y <- all_years ]
         , [ cash_flow            (show y) | y <- all_years ]
         , [ unknown              (show y) | y <- all_years ]
         , [ opening_balances     (show y) | y <- all_years, y/=first ]
         , [ closing_balances     (show y) | y <- all_years, y/=current ]
         ]

-----------------------------------------
-- Extra dependencies of the import files
-----------------------------------------
extraDeps file = []

-----------------------------------------------
-- Extra inputs to be fed to conversion scripts
-----------------------------------------------
extraInputs file = []

main =
  shakeArgs shakeOptions
  export_all

-- Build rules
export_all = do
  want reports

  -- Discover and cache the list of all !includes for the given .journal file, recursively
  year_inputs <- newCache $ \year -> do
    let file = input year
    getIncludes file -- file itself will be included here

  (transactions "//*") %> hledger_process_year year_inputs ["print"]

  (accounts "//*") %> hledger_process_year year_inputs ["accounts"]

  (income_expenses "//*") %> hledger_process_year year_inputs ["is","--flat"]

  (balance_sheet "//*") %> hledger_process_year year_inputs ["balancesheet"]

  (cash_flow "//*") %> hledger_process_year year_inputs ["cashflow","not:desc:(opening balances)"]

  (unknown "//*") %> hledger_process_year year_inputs ["print", "unknown"]

  (closing_balances "//*") %> generate_closing_balances year_inputs

  (opening_balances "//*") %> generate_opening_balances year_inputs

  -- Enumerate directories with auto-generated cleaned csv files
  [ ] |%> in2csv

  -- Enumerate directories with auto-generated journal
  [ ] |%> csv2journal

-------------------------------------
-- Implementations of the build rules
-------------------------------------

-- Run hledger command on a given yearly file. Year is extracted from output file name.
-- To generate '2017-balances', we will process '2017.journal'
hledger_process_year year_inputs args out = do
  let year = head $ split out
  deps <- year_inputs year
  need deps
  (Stdout output) <- cmd "hledger" ("-f" : input year : args)
  writeFileChanged out output

generate_opening_balances year_inputs out = do
  let year = head $ split out
  let prev_year = show ((read year)-1)
  deps <- year_inputs prev_year
  need deps
  (Stdout output) <-
    cmd "hledger"
    ["-f",input prev_year,"equity",open_close_account_query,"-e",year,"--opening"]
  writeFileChanged out output

generate_closing_balances year_inputs out = do
  let year = head $ split out
  hledger_process_year year_inputs ["equity",open_close_account_query,"-e",show (1+(read year)),"-I","--closing"] out

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
  (Stdout output) <- cmd (Cwd source_dir) "./in2csv" (map (makeRelative source_dir) inputs)
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
  (Stdout output) <- cmd (Cwd source_dir) "./csv2journal" [makeRelative source_dir input]
  writeFileChanged out output


-------------------
-- Helper functions
-------------------

-- To get included files, look for '!include'. Note that we cant use "hledger files", as
-- some of the requested includes might be generated by this file and might not exist yet.
getIncludes file = do
  (Stdout output) <- cmd "hledger" ["-f", file, "files"]
  dir <- liftIO $ getCurrentDirectory
  let res = map (makeRelative dir . normaliseEx) $ lines $ output
  return res

split s = takeWhile (/="") $ unfoldr (Just . head . lex) $ takeFileName s

-- Take "dirpath" and return parent dir of "subdir" component
parentOf :: FilePath -> FilePath -> FilePath
parentOf subdir dirpath =
  joinPath $ takeWhile (/= subdir) $ splitDirectories dirpath

-- Take "dirpath" and replace "this" dir component with "that" dir component
replaceDir :: FilePath -> FilePath -> FilePath -> FilePath
replaceDir this that dirpath =
  joinPath $ map (\subdir -> if subdir == this then that else subdir) $ splitDirectories dirpath
