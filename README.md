# "Full-fledged Hledger" Tutorial

Full-Fledged Hledger is a tutorial on how to setup up [hledger](https://github.com/simonmichael/hledger) to get:
- ledger files split by year
- multi-source CSV imports, with "CSV first" workflow where your CSV files treated as a source of truth
- wide range of auto-generated reports
- single script to update all reports when any source file changes, quickly and efficiently
- full freedom to evolve and refactor your journals as you see fit

**All new users please [READ THE WIKI](https://github.com/adept/full-fledged-hledger/wiki) -- at the very least read the 'Getting started' page to get going.**

# Usage

TL;DR: Pick one of the numbered directories:

* [01-getting-started](../../tree/master/01-getting-started)
* [02-getting-data-in](../../tree/master/02-getting-data-in)
* ... and so on

Each numbered directory is self-contained and  includes all the code and source files from preceding directory. Choose a starting point that suits you, clone it to the place of your choosing, run `export.sh`, and start populating your journals. 

Head on to the Wiki to [read the full story of how to grow your setup step by step](https://github.com/adept/full-fledged-hledger/wiki) and decide which bits and pieces you want to adopt.

Feel free to ignore all the scripts at the top level of the repo - they are there to help maintain the project and are not part of the hledger setup.

# Wiki Table of Contents for the impatient

0. [Key principles and practices](https://github.com/adept/full-fledged-hledger/wiki/Key-principles-and-practices)
1. [Getting started](https://github.com/adept/full-fledged-hledger/wiki/Getting-started)
2. [Getting data in](https://github.com/adept/full-fledged-hledger/wiki/Getting-data-in)
3. [Getting full history of the account](https://github.com/adept/full-fledged-hledger/wiki/Getting-full-history-of-the-account)
4. [Adding more accounts](https://github.com/adept/full-fledged-hledger/wiki/Adding-more-accounts)
5. [Creating CSV import rules](https://github.com/adept/full-fledged-hledger/wiki/Creating-CSV-import-rules)
6. [Maintaining CSV rules](https://github.com/adept/full-fledged-hledger/wiki/Maintaining-CSV-rules)
7. [Investments - easy approach](https://github.com/adept/full-fledged-hledger/wiki/Investments-easy-approach)
8. [Mortgages](https://github.com/adept/full-fledged-hledger/wiki/Mortgage)
9. [Remortgage](https://github.com/adept/full-fledged-hledger/wiki/Remortgage)
10. [Foreign currency](https://github.com/adept/full-fledged-hledger/wiki/Foreign-currency)
11. [Sorting `expenses:unknown`](https://github.com/adept/full-fledged-hledger/wiki/Sorting-unknowns)
12. [File-specific rules](https://github.com/adept/full-fledged-hledger/wiki/File-specific-rules)
13. [Tax returns](https://github.com/adept/full-fledged-hledger/wiki/Tax-returns)
14. [Speeding things up](https://github.com/adept/full-fledged-hledger/wiki/Speeding-up)
15. [Tracking commodity lots manually](https://github.com/adept/full-fledged-hledger/wiki/Manual-lot-tracking)
16. [Fetching prices automatically](Fetching-prices)
17. [ChangeLog](https://github.com/adept/full-fledged-hledger/wiki/Changelog)

# What would you find here?

A set of sample journals and helper scripts that I use together with [hledger](http://hledger.org) for tracking personal finances
and budgeting. It should be easily adaptable to other command-line accounting tools (ledger, beancount, ...).

I went through several different approaches over 14 years, and this is the result of that journey, complete with "how", "why" and lessons learned. 

My story is explained on the Wiki and illustrated by the directories
in the repo. You can choose the one that best suits you as a starting
point or look at the [diffs](../../tree/master/diffs) between
different directories to mix and match features as you see fit.

**[CLICK HERE FOR THE WIKI](https://github.com/adept/full-fledged-hledger/wiki)**

# How large is my setup?

According to `hledger stats`, as of 2024 it contains:

* 335 journal files (294 of them autogenerated)
* 7400 days of data
* 32300 transactions
* 12000 payees/descriptions
* 380 accounts (with max depth of 6)
* 22 commodities

So, decently large. It takes about a minute to regenerate all journal files and reports from scratch.

# Read the wiki

Did I mention that you should go and [read the wiki](https://github.com/adept/full-fledged-hledger/wiki)?

# Awk, and Shake, and csvtools, and shell scripts, ...?!

There is [docker image](https://hub.docker.com/r/dastapov/full-fledged-hledger) that includes all the dependencies and tools. Just clone this repo, run `./docker.sh` and you should be all set.

Also, check out [hledger-flow](https://github.com/apauley/hledger-flow) - it might suit you better, as all the automation code is contained in a single binary.
