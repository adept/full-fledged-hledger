# "Full-fledged Hledger" Tutorial

Full-Fledged Hledger is a tutorial on how to setup up hledger to get:
- ledger files split by year
- multi-source CSV imports
- range of auto-generated reports
- single script to update all reports when any source file changes
- full freedom to evolve and refactor your journals as you see fit

**All new users please [READ THE WIKI](https://github.com/adept/full-fledged-hledger/wiki) -- at the very least read the 'Getting started' page to get going.**

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
8. [Remortgage](https://github.com/adept/full-fledged-hledger/wiki/Remortgage)
8. [Foreign currency](https://github.com/adept/full-fledged-hledger/wiki/Foreign-currency)
6. [ChangeLog](https://github.com/adept/full-fledged-hledger/wiki/Changelog)

# What would you find here?

A set of sample journals and helper scripts that I use together with [hledger](http://hledger.org) for tracking personal finances
and budgeting. It should be easily adaptable to other command-line accounting tools (ledger, beancount, ...).

I went through several different approaches over the course of 10 years, and this is the end result of that journey, complete with "how", "why" and lessons learned. 

My story is explained on the Wiki and illustrated by the directories
in the repo. You can choose the one that best suits you as a starting
point or look at the [diffs](../../tree/master/diffs) between
different directories to mix and match features as you see fit.

**[CLICK HERE FOR THE WIKI](https://github.com/adept/full-fledged-hledger/wiki)**

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
