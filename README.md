# Full-fledged Hledger

Full-Fledged Hledger setup which features:
- data split into files by year
- multi-source CSV imports
- range of auto-generated reports
- single script to update all reports when any source file change
- full freedom to evolve and refactor your journals as you see fit

**All new users please [READ THE WIKI](https://github.com/adept/full-fledged-hledger/wiki) -- at the very least read the 'Getting started' page to get going.**

# What is included?

A set of sample journals and helper scripts that I use together with [hledger](http://hledger.org) for tracking personal finances
and budgeting. It should be easily adaptable to other command-line accounting tools (ledger, beancount, ...).

I went through several different approaches over the course of 10 years, and this is the end result of that journey, complete with "how", "why" and lessons learned. 

My story is explained on the Wiki and illustrated by the directories
in the repo. You can choose the one that best suits you as a starting
point and mix or look at the [diffs](../../tree/master/diffs) between
different directories to mix and match features as you see fit.

Evolution of the setup is described in the Wiki.

**[CLICK HERE FOR THE WIKI](https://github.com/adept/full-fledged-hledger/wiki)**

# Installation

Scripts and files here assume Linux-like environment with Haskell (in
particular, you will need `runhaskell` and `stack`) and
textutils/shellutils available. I have not tested them on Mac OS or
Windows. I expect Mac OS to mostly work and Windows users will
probably need to use Docker or virtual machine.

You will need to have `shake` build system installed (which you can
get via `stack install shake`). 

# Usage

TL;DR: Pick one of the numbered directories:
* [01-getting-started](../../tree/master/01-getting-started)
* [02-getting-data-in](../../tree/master/02-getting-data-in)
* ... and so on
Each numbered directory is self-contained and  includes all the code and source files from preceeding directory. Choose a starting point that suits you, clone it to the place of your choosing, run `export.sh`, and start populating your journals. 

Head on to the Wiki to [read the full story of how to grow your setup step by step](https://github.com/adept/full-fledged-hledger/wiki) and decide which bits and pieces you want to adopt.

Feel free to ignore all the scripts at the top level of the repo - they are there to help maintain the project and are not part of the hledger setup.

# Read the wiki

Did I mention that you should go and [read the wiki](https://github.com/adept/full-fledged-hledger/wiki)?
