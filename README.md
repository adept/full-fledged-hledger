# Full-fledged Hledger

Full-Fledged Hledger setup with multiple yearly files, multi-source CSV imports and a range of auto-generated reports.

# What is included?

A set of sample journals and helper scripts that I use together with [hledger](http://hledger.org) for tracking personal finances
and budgeting. It should be easily adaptable to other command-line accounting tools (ledger, beancount, ...).

I went through several different approaches over the course of 10 years, and this is the end result of that journey, complete with "how", "why" and lessons learned

# Installation

Scripts and files here assume Linux-like environment with Haskell (in particular, you will need `runhaskell` and `stack`) and textutils/shellutils available. I have not tested them on Mac OS or Windows.

You will need to have `shake` build system installed (which you can get via `stack install shake`). Scripts used to convert CSV files assume that you will end up having many of them and use GNU `parallel` to run as many conversion jobs as you have CPU cores. If `parallel` is not available, scripts will process files sequentially.

# Usage

TL;DR: Pick one of the numbered branches of this project (`01_getting_started`, `02_getting_data_in`, ...) as a starting point, clone it to the place of your choosing, run `export.sh`, and start populating your journals. 

Head on to the Wiki to [read the full story of how to grow you setup step by step](https://github.com/adept/full-fledged-hledger/wiki).
