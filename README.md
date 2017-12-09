# full-fledged-hledger

Full-Fledged Hledger setup with multi-year files, multi-source imports and a range of auto-generated reports.

## What is this?

This is a set of sample journals and helper scripts that I use together with hledger for tracking personal finances
and budgeting. It should be easily adaptable to other command-line accounting tools (ledger, beancount, ...).

I went through several different approaches over the course of 10 years, and in a sense this is a short story of
how that journey went and where it led.

My goals were:

- Avoid spending too much time, effort and manual work on tracking expenses

- Eventual consistency: even if I can't record something precisely right now, maybe I would be able to do it later

- Ability to refactor. I want to be able to go back and change how I am doing things, with as little effort as possible and without fear of irrevocably breaking things.

Hledger is really flexible and allows you to do whatever you want. Of course quite often it is rather hard to articulate what you want, especially when you are just getting started.
Setup described here provides a nice starting point and helps to gradually get to a point where things are just the way you want them.

Scripts and files here assume Linux-like environment with `runhaskell` and textutils/shellutils available. I have not tested them on Mac OS or Windows.

Every section of this document has a corresponding subdirectory in the repository (`01_getting_started`, `02_getting_data_in`, ...) -- each directory will build upon the previous
one, showing gradual evolution of the setup.

## Getting started

So, you want to keep track of your finances with hledger. You read [hledger step-by-step guide](http://hledger.org/step-by-step.html#useful-accounting-concepts), and you
know the difference between "assets", "liabilities", "equity", "income" and "expenses".

Lets get started. Look into `01_getting_started`, where you will find a completely empty journal for the current year (at the time of writing - 2017) and a couple of export scripts.
Make sure that year of your journal corresponds to the year at the top of  `./export/export.hs`.

If you run `./export.sh`, a bunch of files would be generated in `./export`:

- A list of all transactions for the year, `2017-all.journal`
- Balance sheet for the end of the year: `2017-balance-sheet.journal`
- Closing balances of all assets and liabilities accounts: `2017-closing.journal`
- Income and expense report for the year: `2017-income-expenses.txt`

General idea is to keep this files under version control so that whenever you want to do sweeping changes it would be easy to see what exactly was affected.

## Getting data in

The easiest place to start is with account that is used to fund most of your day-to-day expenses. It is probably a checking/debit/credit card account at the bank of your choice or
a combination of several of them.

You would want to get CSV statements for your account for a reasonable period of time. You can start small: get statement for the last month or a calendar/fiscal year-to-date, and save somewhere
next to your journal. I use `./import/<institution name>/in` for this purpose. For example, at some point my current account was with Lloyds and their statements
will go into `./import/lloyds/in/{filename}.csv`.

Quite often these csv files would not be directly usable with hledgers csv import facility. You might need to do some data scrubbing. I've included a sample data file and conversion scripts in `02_getting_data_in/`. If you run `./convert.sh` in `./import/lloyds`, you will get yourself a nice converted journal in `lloyds/import/journal`.

Here is a crucial bit: instead of copying that file into your journal, lets just `!include` it there. Now you can re-run `./export.sh` and lo and behold: generated reports will now have data in them
and if you are keeping them under version control you shoud be able to see exactly what have changed there.

You will notice that import rules put all all expenses in the 'expenses' account. That's fine, suppose we do not have time to sort them out just now.

## Getting full history of the account

Now that a single statement is succesfully imported, grab all of them, as much as you can get your hands on. Lets assume that you can get 4 years worth of statements. Save them all in the same `in` directory
as your already-converted statement, run `./convert.sh` and hey presto -- you now have full history of your main day-to-day account in a set of nice journal files in `./import/lloyds/journal`.
These journals span 4 year, so you would need more yearly journals: lets create `2014.journal`, `2015.journal` and `2016.journal` and `!include` all newly-converted journal files in there.

When these files are created, a bit of housekeeping should be taken
care of. As a rule, people usually don't want to keep. last year
expenses and keep accumulating current year expenses on top of that.
On the other hand, assets and liabilities can not be left behind and
should be carried over into the next year. To achieve this carry-over,
you need to make sure that your yearly files look like this:

```
!include ./export/{year}-opening.journal

;; !include your converted statements here

!include ./export/{year}-closing.journal
```

File for the earlies year should not have an `!include` for opening balances, and file for current year should not have `!include` for closing balances.

Now, if you edit `./export/export.hs` and change `first` year to be 2014 and re-run `./export.sh`, you will see all the "opening" and "closing" reports generated, along with balance sheets, income-expense statements and other reports for all years from 2014 to 2017.

Remember to put them all under version control.

## Adding more accounts
You probably have more than one account at the same place where you have your current account. It could be current account of your significant other, or a savings account. Statement for this account
would be in the same format, so it should be easy to grab those as well and convert them.

You will need to modify the rules to make sure that account1 is properly set (or inferred from a column in the input file). You will also need to make sure that transfers between accounts are not double-counted.

In `03_getting_full_history/` there are a couple of transfers to the savings account in the current account statements. Now that savings account statements are brought into the picture, they will contain records of these transfers as well, and if we were to include them as-is, balances for both current and savings accounts would be wrong. The trick here is to make transfers face non-existent 'transfers' account, such that line in the current account statement is converted to be a transaction from `assets:Lloyds:current` account to `transfers`, and line in savings account statement is converted to be a transaction from `transfers` to `assets:Lloyds:savings` (after which `transfers` account is flat).

This requires further changes to the rules file and conversion scripts that could be seen in `04_adding_more_accounts/`. As newly-converted journals are `!include`-ed into yearly files and `./export.sh` is re-ran, you can use version control system to verify that yearly balance statements for current account are unchanged (you did put all generated reports under version control to simplify this, didn't you?).

## Classifying expenses
rules in a csv file
TODO

## More detailed expenses with additional statements
TODO


