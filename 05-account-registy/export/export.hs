#!/usr/bin/env stack
-- stack --resolver lts-12.4 script --package shake
import Development.Shake
import Development.Shake.FilePath
import Data.List
import Text.Printf
import Control.Monad

--
-- Range of years to report. You would typically want all the years you have data for.
--
first   = 2014 :: Int
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
transactions     y = y++"-all.journal"
income_expenses  y = y++"-income-expenses.txt"
balance_sheet    y = y++"-balance-sheet.txt"
closing_balances y = y++"-closing.journal"
opening_balances y = y++"-opening.journal"
accounts         y = y++"-accounts.txt"
-- which accounts to include in opening/closing reports
open_close_account_query = "assets|liabilities|debts"

-- Example of the custom report: extract numbers for UK tax report
tax_return y = printf "%d-%d-tax.txt" (y-1) y

--
-- Defining the full set of reports and journals to be generated
--
reports = 
  concat [ [ transactions     (show y) | y <- all_years ]
         , [ accounts         (show y) | y <- all_years ]
         , [ income_expenses  (show y) | y <- all_years ]
         , [ balance_sheet    (show y) | y <- all_years ]
         , opening_closing
         ]

opening_closing =
  concat [ -- closing balances are not generated for the last year
    [ closing_balances (show y) | y <- [first..current-1] ]
    -- opening balances are not generatedfor the first year
    , [ opening_balances (show y) | y <- [first+1..current] ]
    ]
  
main = 
  shakeArgs shakeOptions 
  export_all
  
export_all = do
  want reports
  
  -- Generate list of all !includes for the given .journal file, recursively
  file_and_all_includes <- newCache $ \file -> do 
    includes <- getIncludes file
    return (file:includes) 
  
  -- Set of inputs for one year
  let year_inputs year = do
        input_deps <- file_and_all_includes (input year)
        case year of
          x | x == show first   -> return $ (closing_balances year):input_deps
          x | x == show current -> return $ (opening_balances year):input_deps
          otherwise         -> return $ [opening_balances year, closing_balances year]++input_deps
  
  (transactions "//*") %> \out -> do  
    let year = head $ split out
    deps <- year_inputs year
    need deps
    (Stdout output) <- 
      cmd "hledger" ["-f",input year,"print"]
    writeFileChanged out output
  
  (accounts "//*") %> \out -> do  
    let year = head $ split out
    deps <- year_inputs year
    need deps
    (Stdout output) <- 
      cmd "hledger" ["-f",input year,"accounts"]
    writeFileChanged out output

  (income_expenses "//*") %> \out -> do  
    let year = head $ split out
    deps <- year_inputs year
    need deps
    (Stdout output) <- 
      cmd "hledger" ["-f",input year,"is","--flat"]
    writeFile' out output

  (balance_sheet "//*") %> \out -> do  
    let year= head $ split out
    deps <- year_inputs year
    need deps
    (Stdout output) <- 
      cmd "hledger" ["-f",input year,"balancesheet","not:desc:(closing balances)"]
    writeFile' out output

  (closing_balances "//*") %> \out -> do  
    let year = head $ split out
    need $ filter (/=(opening_balances (show first))) $ [opening_balances year, input year]
    -- ensure that is created empty, if they does not exist
    () <- cmd "touch" [closing_balances year]
    (Stdout output) <- 
      cmd "hledger" 
        ["-f",input year,"equity",open_close_account_query,"not:desc:(closing balances)","-e",show (1+(read year)),"-I"]
    -- Take first transaction, which should be until first empty line
    writeFile' out $ unlines $ takeWhile (/="") $ lines output
  
  (opening_balances "//*") %> \out -> do  
    let year = head $ split out
    let prev_year = show ((read year)-1)
    deps <-year_inputs prev_year
    need deps
    -- ensure that is created empty, if it does not exist
    () <- cmd "touch" [opening_balances year]
    (Stdout output) <- 
      cmd "hledger" 
      ["-f",input prev_year,"equity",open_close_account_query,"not:desc:(closing balances)","-e",year]
    -- Take second/last transaction, which should be after first empty line
    writeFile' out $ unlines $ dropWhile (/="") $ lines output
  where
    getIncludes file = do
      (Stdout output) <- cmd "/usr/bin/awk" [ "/^!include/{print $2}", file ]
      let basenamesIncludedHere = lines output
      let dir = takeDirectory1 file
      let filesIncludedHere = 
            map (addDir dir) 
            -- not chaising includes from opening/closing balances files to 
            -- avoid hitting the cases when they are not created yet.
            $ filter (not.is_opening_closing) 
            $ basenamesIncludedHere
      if filesIncludedHere == [] 
      then return [] 
      else do
        recursiveIncludes <- mapM (getIncludes) filesIncludedHere
        return (filesIncludedHere ++ concat recursiveIncludes)

    is_opening_closing str =
      (opening_balances "") `isSuffixOf` str || (closing_balances "") `isSuffixOf` str

    addDir dir fname@('/':_) = fname
    addDir dir fname = dir </> fname

    split s = takeWhile (/="") $ unfoldr (Just . head . lex) s
