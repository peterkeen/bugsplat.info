Title: Program Your Finances: Vacation Tracking
Date:  2011-08-04 16:47:48
Id:    7e479

*Note: you can find much more information about ledger on [ledger-cli.org](http://ledger-cli.org), including links to official documentation and other implementations*

Recently my girlfriend and I visited the wonderful city of Vancouver, Canada. While out of country we tend to use my [Schwab Investor Checking][schwab] account because it carries no fees whatsoever, including currency conversions, and it refunds all ATM fees. Last year when we went to Ireland we just kept all of the receipts and figured it out when we got back, which was excrutiatingly painful. Lost receipts, invisible cash transactions, ugh. It hurts to even think about it. This year, I decided to cobble together a simple system so we could track on the fly. Read on to see how it came together.

[schwab]: http://www.schwab.com/public/schwab/banking_lending/checking

--fold--

This system has the following moving parts:

 * [Dropbox][]
 * [Ledger][]
 * [Nebulous Notes][], a text editor for iOS that syncs with Dropbox
 * an always-online machine hooked up to Dropbox and capable of running a python script every once in a while
 
The workflow is pretty simple. Whenever we spent some money, I recorded it in a very simplified manner at the bottom of a ledger file that lives in Dropbox. Here's a few examples:

    2011/07/23 Cash
        Cash  160.00 CAD
        ATM Fees  2.50 CAD
        Checking
    
    2011/07/23 SkyTrain tickets
        Transit  5.00 CAD
        Cash
    
    2011/07/24 Acme Cafe
        Food:Breakfast  29.40 CAD
        Checking
    
Note that, while simple, these are all valid ledger entries. They just have a different account structure than what my main ledger uses. I used a different file and an abbreviated account structure for a few reasons. First, using shorter account names means I didn't have to type as much on the iPhone screen. Second, this was an experiment, so having a separate file means I didn't have to worry about corrupting my main ledger. Third, loading up my main ledger on the phone slowed Nebulous Notes to a crawl, which wouldn't have been fun dealing with on the move.

Nebulous Notes also has a great macro system, so I was able to program a few interesting templates. "Go to the bottom of the file", Food, and Transit were all one button.

So, now that we have transactions going in and being synced, let's get a little fancy. This was a frugal vacation, so I wanted to see totals by account while we were out and about. Here's that python script:

    #!/usr/bin/env python
    
    import sys
    import re
    
    amount_by_account = {}
    
    ledger_file = sys.argv[1]
    summary_file = sys.argv[2]
    
    with open(ledger_file) as f:
        for line in f.readlines():
            if len(line.strip()) == 0:
                continue
    
            match = re.match("\s+([\w:]+) \s+([0-9.]+) CAD", line)
            if match is not None:
                account = match.group(1)
                amount = match.group(2)
    
                prev_amount = amount_by_account.get(account, 0.0)
    
                amount_by_account[account] = prev_amount + \
                    float(amount)
                
    
    with open(summary_file, "w+") as f:
        total = 0
        for account in sorted(amount_by_account.keys()):
            total += amount_by_account[account]
            f.write("{0:<20}{1:>10}\n".format(account, "%.2f" %
                (amount_by_account[account])))
    
        f.write("------------------------------\n")
        f.write("{0:<20}{1:>10}\n".format("Total", "%.2f" % total))

Why python and not ledger itself? The machine that I had available to run this thing is a PowerPC Mac mini, which I've never been able to get ledger running properly on. So, python it is! Basically, it looks for lines in `ledger_file` matching the pattern of a ledger posting, totals up the amounts, and prints them out in alphabetical order to `summary_file`, which also lives on Dropbox. I had this on a one-minute `cron` schedule, so whenever I wanted to see our totals (and was in wifi range) I could just open `summary_file` in Nebulous and sync it up.

I could have used one of any number of iOS expense tracking apps, and that might have been the smarter way to go, but what fun would that be? Also, this system automatically backs itself up whenever Nebulous connects to Dropbox AND it lets me do another fun thing: import (almost) directly into my main ledger.

I say "almost" both because of the simplified account structure and because it's in Canadian dollars and my ledger is exclusively US dollars. Problematic! The easiest way to fix this was by applying the power of perl:

    #!/usr/bin/perl
    
    use strict;
    use warnings;
    
    my %rates = (
        '2011/07/23' => 1.0531,
        '2011/07/24' => 1.0531,
        '2011/07/25' => 1.0595,
        '2011/07/26' => 1.0596,
        '2011/07/27' => 1.0619,
        '2011/07/28' => 1.0615,
        '2011/07/29' => 1.0615,
    );
    
    my $current_date = undef;
    
    while (<>) {
        if (/(\d{4}\/\d{2}\/\d{2})/) {
            $current_date = $1;
        }
    
        if (/(\s+)([\w\d: ]+)  (\d+(\.\d+)?)/) {
            $_ = sprintf(
                "%sExpenses:%s  \$%.2f\n",
                $1,
                $2,
                ($3 * $rates{$current_date})
            );
        }
    
        s/    Cash/    Expenses:Cash/;
    
        s/Checking/Assets:Schwab:Checking/;
        print $_
    }
    
Oh perl. So useful. So ugly. For every line, if it looks like a date, save off the date. If it looks like a transaction line, do the currency conversion (rates are calculated by picking a sample transaction from the bank and backing into it). If it looks like a `Cash` or `Checking` account, replace it with the long form of the account name. Finally, print it back out. This got me most of the way there, but I had to tweak some of the amounts due to posting lag at the bank and using a different day's conversion rate. I also piped it through ledger to get the formatting cleaned up:

    $ convert-vancouver-ledger.pl vancouver_ledger.txt | \
      ledger -f - print > final_ledger_file.txt

A few quick adjustments and sanity checks later and I was able to copy and paste into my main ledger. I also added some metadata so I could get a report for my girlfriend so she could see what we spent and write me a check for half. Frugal, remember? The final transactions ended up looking like this:

    2011/07/23 * Cash
        ; :vancouver:
        Expenses:Cash                            $168.51
        Expenses:ATM Fees                          $2.63
        Assets:Schwab:Checking
    
    2011/07/23 * SkyTrain tickets
        ; :vancouver:
        Expenses:Transit                           $5.27
        Expenses:Cash
    
    2011/07/24 * Acme Cafe
        ; :vancouver:
        Expenses:Food:Breakfast                   $31.15
        Assets:Schwab:Checking

I think it turned out pretty well. I spent less than an hour the day after we got home getting everything cleaned up and copied into my main ledger. When we next go out of the country, I'm sure I'll use this same system. I'll probably put the summarizer script in Dropbox, though, so I can tweak it if necessary.

*Have you been in this situation and done something different? Leave a comment!*

[Dropbox]: http://www.dropbox.com
[Ledger]: http://www.ledger-cli.org
[Nebulous Notes]: http://nebulousapps.net/notes.html