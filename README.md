# full-fledged-hledger

Full-Fledged Hledger setup with multiple yearly files, multi-source CSV imports and a range of auto-generated reports.

Pick one of the numbered sub-directories here as a starting point, copy it to the place of your choosing, run `export.sh`, place everything under version and start
populating your journals. Read on for a full story.

## What is this?

This is a set of sample journals and helper scripts that I use together with hledger for tracking personal finances
and budgeting. It should be easily adaptable to other command-line accounting tools (ledger, beancount, ...).

I went through several different approaches over the course of 10 years, and in a sense this is a short story of
how that journey went and where it led.

## Goals

I wanted setup that would enable me to have:

- Avoid spending too much time, effort and manual work on tracking expenses

- Eventual consistency: even if you can't record something precisely right now, maybe I would be able to do it later

- Ability to refactor. I want to be able to go back and change how I am doing things, with as little effort as possible and without fear of irrevocably breaking things.

## Key principles and approaches

### Version control everything

Put your journal under version control - this would save you from yourself, you would be able to make sweeping edits of your journals (renaming accounts, etc) without fear of messing things up or losing everything.

Put all the electronic statements that you've incorporated into your journal under version control as well. If your bank changes the format of the statements and new statements happen to be better than the old ones (more information is available, etc), you would be able to regenerate all past statements and see what was changed and convince yourself that numbers will stay the same. 

If you generate any reports on the regular basis (balance sheet, income-expenses, etc) - make scripts to generate them and put them under version control. Now you can change your journal files however you like and you would be able to check changes in the reports to convince yourself that your journal changes are good and complete.

### Keep source files separate and use !include a lot

When you convert electronic statements, produce one .journal file per statement converted, put them under version control and !include them in your journal. Now, if your statements ever change, you would be able to re-generate corresponding .journal file and aggregate reports (like balance sheet) and see the changes that happened at every step of the way. Example use-case would be: you made a mistake collecting statements and exported same month twice, and now you have re-acquired one of the statements or manually edited it to remove duplicated rows.

### Generate a lot of reports automatically after every significant change

Whenever you are done reconciling your accounts (or part of them), generate a lot of reports. Have a script that does that in "one click". Keep reports under version control. This way you would be able to spot weird or out-of-place things that happened after any change to your journals.

### Minimize manual entries

Manual entries take time. They would probably take more time and effort than the rest of the stuff related to keeping your finances in check, combined. Think whether you want to track all those cash expenses. Do you need to?

Any ATM transactions in my bank accounts are done versus `expenses:misc:cash`, and unless monthly amount there get out of check, I never bother detailing them, and I strongly suggest you do the same -- unless you handle a lot of cash.

### Split your journals by year

This make things faster and also allows you to reset your expenses at a reasonable interval. Hledger and ledger have helpful `equity` command to simplify the process, but you can simplify it even further with some scripting.

### Refactor and change aggressively

If you have an ability to easily re-generate journal files from all of your electronic statements, you can tweak CSV import rules to improve classification of your transactions or change it if current classification does not suit your need.

Changing CSV import rules and re-generating .journal files from all the source statements allows you to be more confident in the result as compared to mass search and replace over report files.

### Add more details over time

It is realitvely easy to find yourself with a setup where you drop fresh CSV statements in a directory from time to time, run a couple of scripts, review changes in version control system, and your are done with next batch of reconciliation.

Freed-up time can be used to get more statements from more sources that will provide you with a more fine-grained picture. For example, you might pay off your credit card from your current account every month, and these lump-sump expenses went into `expenses:credit card`, but now you can consider getting detailed statements from credit card provider. Now transactions that pay off your outstanding balance can go to `liabilities:credit card:balance payments` and credit card statement could be processed so that credit card spending goes from `liabilities:credit card` to various `expenses:...` accounts, and credit card balance payments go from `liabilities:credit card:balance payments` to `liabilities:credit card`.

Once you have things in place to process credit card statements, you can change one CSV conversion rule for the current account that influences how credit card balance payments are processed, regenerate all current account .journals and have detailed information about credit card spendings.

Same thing could be done with Amazon, Paypal, your pension account, savings and brokerage accounts, etc - you can start with treating them as black boxes or expense categories, and then with time procure statements for them and incorporate them. If everything is under version control, it would be easy to do that and check that all aggregate reports react accordingly.

## What is in here and how to use it

Scripts and files here assume Linux-like environment with `runhaskell` and textutils/shellutils available. I have not tested them on Mac OS or Windows.

Repository contains a number of subdirectories (`01_getting_started`, `02_getting_data_in`, ...) that represent gradual evolution of the setup, starting from the smallest
possible and gradually adding more and more features in. This way you can either choose the starting point that is more suitable for you or compare/diff various setups and see
what exactly have been changed to add each particular feature.

The bigger the number, the more features/examples are incorporated.

## Directory structure

At top level, there would be a number of yearly journals, one per year (`2014.journal`, `2015.journal`, etc).

Each of them will `!include` a bunch of files from `./import/{statement source}/journal/` subdirectories and will also contain all manual transactions for the given year.

Script `export.sh` is used to generate a bunch of reports in the `export` subdirectory, which contains [Shake](http://shakebuild.com/) script `./export/export.sh` that drives whole process.

All source statements go into `./import/{statement source}/in`, then they are converted to proper CSV files and put into `./import/{statement source}/csv` and generated journal files go into `./import/{statement source}/journal`. I usually have `./import/{statement source}/convert.sh` that allows you to re-generate all files in `./journal` from the source files held in `./in`.

Typical filesystem tree will look like this:
```
├── 2014.journal
├── 2015.journal
├── 2016.journal
├── 2017.journal
├── export
│   ├── 2014-all.journal
│   ├── 2014-balance-sheet.txt
│   ├── 2014-closing.journal
│   ├── 2014-income-expenses.txt
│   ├── 2015-all.journal
│   ├── 2015-balance-sheet.txt
│   ├── 2015-closing.journal
│   ├── 2015-income-expenses.txt
│   ├── 2015-opening.journal
│   ├── 2016-all.journal
│   ├── 2016-balance-sheet.txt
│   ├── 2016-closing.journal
│   ├── 2016-income-expenses.txt
│   ├── 2016-opening.journal
│   ├── 2017-all.journal
│   ├── 2017-balance-sheet.txt
│   ├── 2017-closing.journal
│   ├── 2017-income-expenses.txt
│   ├── 2017-opening.journal
│   └── export.hs
├── export.sh
└── import
    └── lloyds
        ├── convert.sh
        ├── csv
        │   ├── 12345678_20171225_0001.csv
        │   ├── 12345678_20171225_0002.csv
        │   ├── 99966633_20171223_1844.csv
        │   ├── 99966633_20171224_2041.csv
        │   ├── 99966633_20171224_2042.csv
        │   └── 99966633_20171224_2043.csv
        ├── in
        │   ├── 12345678_20171225_0001.csv
        │   ├── 12345678_20171225_0002.csv
        │   ├── 99966633_20171223_1844.csv
        │   ├── 99966633_20171224_2041.csv
        │   ├── 99966633_20171224_2042.csv
        │   └── 99966633_20171224_2043.csv
        ├── journal
        │   ├── 12345678_20171225_0001.journal
        │   ├── 12345678_20171225_0002.journal
        │   ├── 99966633_20171223_1844.journal
        │   ├── 99966633_20171224_2041.journal
        │   ├── 99966633_20171224_2042.journal
        │   └── 99966633_20171224_2043.journal
        ├── lloyds2csv.pl
        └── lloyds.rules
```

# How to build a setup like this

## Getting started

So, you want to keep track of your finances with hledger. You read [hledger step-by-step guide](http://hledger.org/step-by-step.html#useful-accounting-concepts), and you
know the difference between "assets", "liabilities", "equity", "income" and "expenses".

Lets get started. Look into `01_getting_started`, where you will find a completely empty journal for the current year (at the time of writing - 2017) and a couple of export scripts.
Make sure that year of your journal corresponds to the year at the top of  `./export/export.hs`.

If you run `./export.sh`, a bunch of files would be generated in `./export`:
```
export
├── 2017-all.journal           - a list of all transactions for the year
├── 2017-balance-sheet.txt     - balance sheet for the end of the year
├── 2017-closing.journal       - closing balances of all assets and liabilities accounts
├── 2017-income-expenses.txt   - income and expense report for the year
└── export.hs                  - Shake build script that describes how these reports are generated
```

General idea is to keep this files under version control so that whenever you want to do sweeping changes it would be easy to see what exactly was affected.

## Getting data in

The easiest place to start is with account that is used to fund most of your day-to-day expenses. It is probably a checking/debit/credit card account at the bank of your choice or
a combination of several of them.

You would want to get CSV statements for your account for a reasonable period of time. You can start small: get statement for the last month or a calendar/fiscal year-to-date, and save somewhere
next to your journal. I use `./import/<institution name>/in` for this purpose. For example, at some point my current account was with Lloyds and their statements
will go into `./import/lloyds/in/{filename}.csv`

Quite often these csv files would not be directly usable with hledgers csv import facility. You might need to do some data scrubbing. I've included a sample data file and conversion scripts in `02_getting_data_in/`. If you run `./convert.sh` in `./import/lloyds`, you will get yourself a nice converted journal in `lloyds/import/journal`:
```
import
└── lloyds
    ├── convert.sh                           - conversion script. This is what you will run
    ├── lloyds2csv.pl                        - helper script to clean up downloaded statements
    ├── in
    │   └── 99966633_20171223_1844.csv       - original downloaded file
    ├── csv
    │   └── 99966633_20171223_1844.csv       - cleaned up file, ready to be consumed by hledger
    ├── journal
    │   └── 99966633_20171223_1844.journal   - generated journal
    └── lloyds.rules                         - CSV conversion rules
```

Here is a crucial bit: instead of copying that file into your journal, lets just `!include` it there. Now you can re-run `./export.sh` and lo and behold: generated reports will now have data in them
and if you are keeping them under version control you shoud be able to see exactly what have changed there.

You will notice that import rules put all all expenses in the 'expenses' account. That's fine, suppose we do not have time to sort them out just now.

## Getting full history of the account

Now that a single statement is succesfully imported, grab all of them, as much as you can get your hands on. Lets assume that you can get 4 years worth of statements. Save them all in the same `in` directory
as your already-converted statement, run `./convert.sh` and hey presto -- you now have full history of your main day-to-day account in a set of nice journal files in `./import/lloyds/journal`:
```
import
└── lloyds
    ├── convert.sh
    ├── in                                   - original yearly statements
    │   ├── 99966633_20171223_1844.csv
    │   ├── 99966633_20171224_2041.csv
    │   ├── 99966633_20171224_2042.csv
    │   └── 99966633_20171224_2043.csv
    ├── csv                                  - cleaned up files, ready to be consumed by hledger
    │   ├── 99966633_20171223_1844.csv
    │   ├── 99966633_20171224_2041.csv
    │   ├── 99966633_20171224_2042.csv
    │   └── 99966633_20171224_2043.csv
    ├── journal                              - generated journals
    │   ├── 99966633_20171223_1844.journal
    │   ├── 99966633_20171224_2041.journal
    │   ├── 99966633_20171224_2042.journal
    │   └── 99966633_20171224_2043.journal
    ├── lloyds2csv.pl
    └── lloyds.rules
```

Generated journals span 4 year, so you would need more yearly journals: lets create `2014.journal`, `2015.journal` and `2016.journal` and `!include` all newly-converted journal files in there.

When these files are created, a bit of housekeeping should be taken
care of. As a rule, people usually don't want to retain last year
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

Note that we are `!include`ing files from `./export` - they would be auto-generated, you will not have to generate them manually.

Now, if you edit `./export/export.hs` and change `first` year to be 2014 and re-run `./export.sh`, you will see all the "opening" and "closing" reports generated, along with balance sheets, income-expense statements and other reports for all years from 2014 to 2017:
```
export
├── 2014-all.journal
├── 2014-balance-sheet.txt
├── 2014-closing.journal
├── 2014-income-expenses.txt
├── 2015-all.journal
├── 2015-balance-sheet.txt
├── 2015-closing.journal
├── 2015-income-expenses.txt
├── 2015-opening.journal
├── 2016-all.journal
├── 2016-balance-sheet.txt
├── 2016-closing.journal
├── 2016-income-expenses.txt
├── 2016-opening.journal
├── 2017-all.journal
├── 2017-balance-sheet.txt
├── 2017-closing.journal
├── 2017-income-expenses.txt
├── 2017-opening.journal
└── export.hs
```

Remember to put them all under version control.

## Adding more accounts
You probably have more than one account at the same place where you have your current account. It could be current account of your significant other, or a savings account. Statement for this account
would be in the same format, so it should be easy to grab those as well and convert them.

You will need to modify the rules to make sure that `account1` is properly set (or inferred from a column in the input file). Apart from that, the rest is easy -- you drop statements in `./in`, run `convert.sh` and `!include` generated journals as necessary:
```
import
└── lloyds
    ├── convert.sh
    ├── csv
    │   ├── 12345678_20171225_0001.csv
    │   ├── 12345678_20171225_0002.csv
    │   ├── 99966633_20171223_1844.csv
    │   ├── 99966633_20171224_2041.csv
    │   ├── 99966633_20171224_2042.csv
    │   └── 99966633_20171224_2043.csv
    ├── in
    │   ├── 12345678_20171225_0001.csv
    │   ├── 12345678_20171225_0002.csv
    │   ├── 99966633_20171223_1844.csv
    │   ├── 99966633_20171224_2041.csv
    │   ├── 99966633_20171224_2042.csv
    │   └── 99966633_20171224_2043.csv
    ├── journal
    │   ├── 12345678_20171225_0001.journal
    │   ├── 12345678_20171225_0002.journal
    │   ├── 99966633_20171223_1844.journal
    │   ├── 99966633_20171224_2041.journal
    │   ├── 99966633_20171224_2042.journal
    │   └── 99966633_20171224_2043.journal
    ├── lloyds2csv.pl
    └── lloyds.rules
```

You migh also need to make sure that transfers between accounts are not double-counted.

Current account statements that were dealt with in `03_getting_full_history/` included a couple of transfers from current to savings account. Now that savings account statements are brought into play, they will contain records of these transfers as well, and if we were to include them as-is, balances for both current and savings accounts would be wrong:
```
; In current account
2017-12-02 Transfer to savings
   assets:Lloyds:current  $-500
   assets:Lloyds:savings

; In savings account
2017-12-02 Transfer from current
   assets:Lloyds:savings  $500
   assets:Lloyds:current
```

The trick here is to make transfers face non-existent 'transfers' account, such that line in the current account statement is converted to be a transaction from `assets:Lloyds:current` account to `transfers`, and line in savings account statement is converted to be a transaction from `transfers` to `assets:Lloyds:savings` (after which `transfers` account is flat):
```
; In current account
2017-12-02 Transfer to savings
   assets:Lloyds:current  $-500
   assets:Lloyds:transfers

; In savings account
2017-12-02 Transfer from current
   assets:Lloyds:savings  $500
   assets:Lloyds:transfers
```

This requires further changes to the rules file and conversion scripts that could be seen in `04_adding_more_accounts/`.

As newly-converted journals are `!include`-ed into yearly files and
`./export.sh` is re-ran, you can use version control system to verify
that yearly balance statements for current account are unchanged (you
did put all generated reports under version control to simplify this,
didn't you?).


