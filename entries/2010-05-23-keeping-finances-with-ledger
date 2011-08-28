Title: Program your Finances: Command-line Accounting
Date:  2010-05-23 15:15:00
Id:    7

*Note: you can find much more information about ledger on [ledger-cli.org](http://ledger-cli.org), including links to official documentation and other implementations*

About three years ago I was in some serious financial straits. I had just started my first job out of college that I had moved across the country for and had to bootstrap almost my whole life. This meant buying furniture, buying a car, outfitting a kitchen, etc. Every two weeks I would get a salary deposit, and within two weeks it would be almost completely gone from my checking account. I actually bounced a rent check or two in there. After the second time that happened I vowed it wouldn't happen again and started keeping track of every penny that I spent using a program called [ledger][]. This was, in hindsight, exactly what I needed to get myself back on track. Actually seeing money moving in and out of my accounts forced me to modify my behavior. At the time, [Mint](http://www.mint.com/) wasn't around, but I don't think it would have helped nearly as much. Forcing myself to actually type out the transactions was the key to changing behavior.

Ledger is almost the most boring, austere accounting program you could think of. There's no pretty graphs, no online interaction, no GUI of any sort. It's basically a command-line driven calculator with a lot of specializations that make it ideal for tracking finances, which is what makes it so ideal for someone who spends a lot of time inside a text editor. It's very easy to script around and it has a very rich query language that lets you get at the data that you want with a minimum of fuss. It's very much the inspiration for [Calorific][].

The basic idea is that you write down all of your financial transactions in a text file with an easy-to-master syntax and then run the `ledger` command on them to generate reports. Here's a simplified extract from my ledger file:

<pre>
2010/05/20 * Opening Balances
    Assets:Checking                          $500.00
    Liabilities:Amex                         $-10.00
    Equity

2010/05/21 * Salary
    Assets:Checking                        $1,000.00
    Expenses:Taxes:Federal                   $250.00
    Expenses:Taxes:State                     $100.00
    Expenses:Taxes:Social Security            $80.00
    Expenses:Insurance:Medical                $20.00
    Expenses:Insurance:Dental                  $2.00
    Income:Salary                         $-1,452.00

2010/05/21 Rent
    Expenses:Rent                            $600.00
    Assets:Checking

2010/05/21 Pacific Power
    Expenses:Utils:Electric                   $61.75
    Assets:Checking

2010/05/21 * AT&T Wireless
    Expenses:Cell Phone                       $88.46
    Assets:Checking

2010/05/22 NW Natural
    Expenses:Utils:Gas                        $20.31
    Assets:Checking

2010/05/22 Pizzicato
    Expenses:Food:Lunch                        $7.90
    Assets:Checking

2010/05/23 Comcast
    Expenses:Cable                            $60.00
    Liabilities:Amex
</pre>

This is actually a complete ledger file (you can download it [here](ledger.sample.txt)) that illustrates a few key points. First, ledger is a double-entry accounting system. Every entry has at least one *from* and at least one *to*. Generally, the first line of the entry is where the money goes *to*, and it's a positive amount, with the second line being where the money comes *from*. If you leave off the amount of one of the lines ledger will automatically fill it in and make the entry balance. If you have an accounting background you can think of *from* and *to* in terms of debits and credits, but ledger doesn't force that. Second, accounts have a hierarchical namespace, which we can see like this:

<pre>
$ ledger -f ledger.sample.txt -s bal
             $721.58  Assets:Checking
            $-490.00  Equity
           $1,290.42  Expenses
              $60.00    Cable
              $88.46    Cell Phone
               $7.90    Food:Lunch
              $22.00    Insurance
               $2.00      Dental
              $20.00      Medical
             $600.00    Rent
             $430.00    Taxes
             $250.00      Federal
              $80.00      Social Security
             $100.00      State
              $82.06    Utils
              $61.75      Electric
              $20.31      Gas
          $-1,452.00  Income:Salary
             $-70.00  Liabilities:Amex
</pre>

This arrangement of accounts helps to maintain some sanity when dealing with lots of accounts, and it jives with the basic accounting equation: `assets = liabilities + equity + (income - expenses)`. You'll notice that accounts just appear when you use them, sort of variables in perl without `use strict;`. This is both a blessing and a curse, because sometimes it's not obvious that you're misspelling things until you run reports and they look funny. The risk of messing up is mitigated if you use emacs by the bundled `ledger.el` major mode, which sets up tab completion for you.

Again using the example file, we can run some more detailed reports. For example, here's our checkbook register:

<pre>
$ ledger -f ~/Documents/blog/static/ledger.sample.txt -r reg checking
2010/05/20 Opening Balances     Liabilities:Amex             $10.00       $10.00
                                Equity                      $490.00      $500.00
2010/05/21 Salary               Expenses:Taxes:Federal     $-250.00      $250.00
                                Expenses:Taxes:State       $-100.00      $150.00
                                Ex:Ta:Social Security       $-80.00       $70.00
                                Ex:Insurance:Medical        $-20.00       $50.00
                                Ex:Insurance:Dental          $-2.00       $48.00
                                Income:Salary             $1,452.00    $1,500.00
2010/05/21 Rent                 Expenses:Rent              $-600.00      $900.00
2010/05/21 Pacific Power        Ex:Utils:Electric           $-61.75      $838.25
2010/05/21 AT&T Wireless        Expenses:Cell Phone         $-88.46      $749.79
2010/05/22 NW Natural           Expenses:Utils:Gas          $-20.31      $729.48
2010/05/22 Pizzicato            Expenses:Food:Lunch          $-7.90      $721.58
</pre>

Ledger will abbreviate account names as necessary when printing to make it fit in 80 columns. If you have a wider terminal you can pass the `-w` option to make it fit to 132 columns.

The power of ledger really comes into focus when you have more data available. One of the most interesting reports that I run gives me an idea of how I'm doing month-to-month by showing how much my assets have changed (negative numbers are better, in this case): `ledger -MAn reg income expenses liabilities`. The `-M` option groups transactions by month, `-A` will show the running average in the second column. By default it will show the running total. `-n` will group all transactions together, instead of showing one subtotal for each account. It's sort of boring with the sample file, though:

<pre>
$ ledger -f ~/Documents/blog/static/ledger.sample.txt -MAn reg income expenses
2010/05/01 - 2010/05/23         &lt;Total&gt;                    $-161.58     $-161.58
</pre>

In any of these examples you can change the output format to suit your needs. There are a lot of options here that are detailed in the [manual][] (pdf), but here's one example. I have a little program in my bin directory called `transpose`, which takes three-column pipe-separated data and turns it into tab-separated values ready to be inserted into a spreadsheet. The first column is the row, the second column is the column, the third is the value to put in that cell. We can tell ledger to output, for example, a basic expense report formatted for transpose like this:

<pre>
$ ledger -f ~/Documents/blog/static/ledger.sample.txt -F '%A|%D|%t\n' -M reg income expenses
Expenses:Cable|2010/05/01|$60.00
Expenses:Cell Phone|2010/05/01|$88.46
Expenses:Food:Lunch|2010/05/01|$7.90
Expenses:Insurance:Dental|2010/05/01|$2.00
Expenses:Insurance:Medical|2010/05/01|$20.00
Expenses:Rent|2010/05/01|$600.00
Expenses:Taxes:Federal|2010/05/01|$250.00
Expenses:Taxes:Social Security|2010/05/01|$80.00
Expenses:Taxes:State|2010/05/01|$100.00
Expenses:Utils:Electric|2010/05/01|$61.75
Expenses:Utils:Gas|2010/05/01|$20.31
Income:Salary|2010/05/01|$-1,452.00
</pre>

With more data, this lets you easily compare month-to-month where you are spending money.

If you want to pull your financial life together but don't want to spend money on something like Quicken or trust Mint with your account credentials, I highly encourage you to try out ledger in addition to the other open source solutions like gnucash.  All of these examples assume you're using version 2.6.2 of ledger, which you can download from the "Downloads" tab in github. Version 3.0 is just around the corner and it adds all kinds of neat things, including better automated transactions and a much more robust query language.

[ledger]:    http://wiki.github.com/jwiegley/ledger/
[manual]:    http://github.com/downloads/jwiegley/ledger/ledger.pdf
[Calorific]: http://github.com/peterkeen/calorific
