Title: Program your Finances: Reporting for Fun and Profit
Date:  2011-07-09 08:14:55
Id:    4b79e

*Note: you can find much more information about ledger on [ledger-cli.org](http://ledger-cli.org), including links to official documentation and other implementations*

Last year I wrote what ended up being the most popular article on this blog ever, [Program Your Finances: Command-line Accounting](http://bugsplat.info/2010-05-23-keeping-finances-with-ledger.html). That post went over how I track and report on my finances using a program called [Ledger](http://www.ledger-cli.org) along with a few helper scripts. Recently I expanded that toolset quite a bit and wanted to show how keeping meticulous track of your finances can give you superpowers. Read on for the gory details.

--fold--

### Stan the Example Man

Talking about personal finances is kind of a tricky thing. If you want to give anything more than a cursory treatment of the subject you have to have some data but the closest source of data to hand is always your own. [Some][getrichslowly] [people][consumerismcommentary] have decided to talk publicly about their data but I'm not quite ready to to that. Instead, I've written a [little python tool][ledger-tools-generate] to generate a plausible but random history when given a simple json config file. Here's a super simple example: 

    [
        {
            "payee": "Kettleman Bagels",
            "dow": 3,
            "postings": [
                ["Expenses:Food:Breakfast", [7.20, 7.80]],
                ["Assets:Checking"]
            ]
        }
    ]

This says, "Every day on Thursday, buy breakfast at Kettleman Bagel Company. It should cost between $7.20 and $7.80." The `dow` key is the day number, where 0 is Monday and 6 is Sunday. The `postings` array gives a list of Ledger postings that should be inserted for this entry. The first element is the account name, the second is one of: a single float representing the amount in dollars; empty, meaning that this entry should be the balance of all the other entries; or an array of arguments to pass to Python's [random.triangular][python-random-triangular] function. There are a bunch more options that I won't get into here but you can see in the github repo.

Using `generate.py` and [this config][ledger-tools-stan-json], I've created a [ledger file][ledger-tools-stan] for a gentleman who we'll call Stan. Why "Stan"? Because he's the man, that's why. Stan is an unattached twenty-something software developer living in Portland, Oregon. He has a car, a moderately sized student loan, and a pretty decent apartment in a so-so area of town. He's been tracking his expenses for almost four years using Ledger, and he's pretty good at it now. (For the curious, Stan is loosely based on me. Simplified in places, exaggerated in others, cheerfully optimistic in salary.)

### Reporting? What's that mean?

Collecting all of this data wouldn't be worth a whole lot if I couldn't analyze it in various ways. Ledger lets me look at things lots of really interesting ways, but sometimes it's a little bit too low level. Too nitty gritty. Too miss-forest-for-the-trees. Sometimes I want to step back and get a bigger view of where my financial life has been, and were I can expect it to lead, and maybe where I should make some changes. When a business wants to do this, they create a series of financial reports. Lots of businesses are compelled to do this by the SEC because they're public corporations, but every well-run business will create these reports regularly to help them keep on track.

Well, I'm kind of a business, right? I do work and receive money as the result of that work. I have short and long term debt, investments, equitiy, assets, etc etc. My sole motivation isn't profit, of course, but in a lot of other respects I try to run my finances as if they were a business. To that end, I've made a series of tools that produce a [suite of reports][report-example] that are fairly similar to what a business would want. From top to bottom we have:

- **Balance sheet** A snapshot of important accounts and a general idea of "net worth" over time. 
- **Net worth chart** A monthly overview of the "Total" line from the balance sheet for all available months.
- **Income Statement** A monthly breakdown of income, expenses, and liability payments. 
- **Burn Rate** Given Stan spends the "Burn" column on average every month for the trailing 12 months and assuming he'll spend about that same amount going forward, his savings will last him "Months" months. He'll run out of money sometime in February 2012.

### But Ledger is a command line program!

Ledger is a command-line program, that's true. I couldn't go directly from my ledger file to pretty html reports with charts and tables, so I invoked two of my favorite chainsaws to hack this out: [PostgreSQL][] and [python][]. PostgreSQL is a wonderfully powerful database that happens to be open source and community driven, and also very easy to use. Python is, well, it wouldn't have been my first choice until pretty recently, but now that I've started using it perl has kind of dropped off my radar. It's pretty great.

Here's the outline of how this thing works:
 1. Start maintaining a ledger file
 1. Create a PostgreSQL database with the [ledger schema][ledger-tools-schema]

 1. Export the ledger to csv using `ledger csv` and load it into PostgreSQL using [load_ledger.sh][ledger-tools-load]
 1. Run some sort-of complicated queries and dump them into HTML tables using [run_reports.py][ledger-tools-run-report]
 1. Style the html tables using [jquery.datatables][] and build a chart using [jqplot][] 

When I started this I knew I wanted a sql database. I chose PostgreSQL in particular over sqlite both out of familiarity, but also because it handles dates so well. Date is a top-level data type in postgres, instead of having to do weird things with strings like in sqlite.

Why a SQL database instead of just futzing with stuff in python data structures? Because in SQL I can express a rotated dataset pretty easily, whereas in python it would have been a *lot* of code. See run_reports.py for examples of this. Also, it lets me index the hell out of the tables, build summary tables with weird conditions, and still be able to do neat queries.

### Neat Queries You Say?

Honestly, with a lot of work these reports could have been expressed using straight ledger without involving the database at all. It would have been nastier and terser and kind of weird, but I could have done it.

Here's a query that ledger would not have been able to do as far as I know, however:

    select
        xtn_month,
        sum(case when pay_period = 1 then amount else 0 end) as pp1,
        sum(case when pay_period = 2 then amount else 0 end) as pp2
    from
        aggregated_accounts
    where
        account ~ 'Expenses'
        and account !~ 'Taxes'
        and account !~ 'Interest'
    group by
        xtn_month
    where
        xtn_month >= '2011-01-01'
    order by
        xtn_month;


     xtn_month  |   pp1   |   pp2   
    ------------+---------+---------
     2011-01-01 |  418.79 | 1249.39
     2011-02-01 |  477.18 | 1146.11
     2011-03-01 |  432.92 | 1316.65
     2011-04-01 |  439.95 | 1274.56
     2011-05-01 |  385.60 | 1417.73
     2011-06-01 |  547.77 | 1193.86
     2011-07-01 |  189.75 |       0        
    
Being able to group by completely arbitrary things in ledger has been a pain point for me since I started using it. In this case, I'm grouping by `pay_period`, a column that has this definition in aggregated_accounts:

    CASE
        WHEN (
            xtn_date >= '2010-12-05'
            and extract('day' from xtn_date) between 1 and 14
         ) THEN 1
        WHEN (
            xtn_date < '2010-12-05'
            and (
                extract('day' from xtn_date) between 1 and 6
                or extract('day' from xtn_date) between 22 and 31
            )
        ) THEN 1
        ELSE 2
    END as pay_period
    
The "Burn" calculations are another example. Before I had the data in postgres I had an extremely messy shell script that invoked `ledger`, `date`, and `dc` to calculate it, and if anything broke it all fell down with a weird error.

### Drawbacks

The only drawback right now is that the postgres/python setup can't handle differing commodities very well. I track my investment accounts in ledger right along side my transactional accounts and ledger has the ability to go download price quotes for the holdings in those accounts whenever you want and do various calculations on them, but the way I'm doing the CSV export right now doesn't do any of that.

### Conclusion

With this setup, I'm able to keep my financial data in a simple, easy to use format and retain the ability to do quick checks on it using `ledger`. In addition, I can do compilcated queries that would get extremely nasty in straight ledger. It's really the best of both worlds. I've put the tools on [GitHub][ledger-tools] if you want to check them out and maybe install them and try them out.

*Whew! Did you stick it out? Questions? Comments? Post'em below.*

[Ledger]: http://ledger-cli.org
[getrichslowly]: http://www.getrichslowly.org
[consumerismcommentary]: http://www.consumerismcommentary.com/category/monthly-update/
[ledger-tools]: https://github.com/peterkeen/Ledger-Tools-Demo/
[ledger-tools-generate]: https://github.com/peterkeen/Ledger-Tools-Demo/blob/master/generate.py
[ledger-tools-stan-json]: https://github.com/peterkeen/Ledger-Tools-Demo/blob/master/stan.json
[ledger-tools-stan]: https://github.com/peterkeen/Ledger-Tools-Demo/blob/master/stan.txt
[ledger-tools-run-report]: https://github.com/peterkeen/Ledger-Tools-Demo/blob/master/run_reports.py
[ledger-tools-load]: https://github.com/peterkeen/Ledger-Tools-Demo/blob/master/load_ledger.sh
[ledger-tools-schema]: https://github.com/peterkeen/Ledger-Tools-Demo/blob/master/ledger-schema.sql
[python-random-triangular]: http://docs.python.org/library/random.html#random.triangular
[report-example]: static/stan-demo-report.html
[PostgreSQL]: http://www.postgresql.org/
[Python]: http://www.python.org/
[jquery.datatables]: http://www.datatables.net/
[jqplot]: http://www.jqplot.com/
