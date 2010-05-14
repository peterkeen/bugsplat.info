Title: Actionable Information
Date:  2010-05-12 08:53:00
Id:    5

Let's pretend, just for a second, that you want to make some money on the stock market. Sounds easy, right? Buy low, sell high, yadda yadda blah blah blah. Except, how do you know when to buy and when to sell? Not so easy. Being a nerd, you want to teach your computer how to do this for you. But where to start? I discovered a few months ago that there are [services][1] [out][2] [there][3] that will sell you a data feed that literally blasts every single anonymous transaction that happens on any market in the US in real time. They'll also sell you access to a historical feed that provides the same tick-level information going back for several years.

So, ok, you've got a whole lot of raw data. All kinds of fun problems come from having a huge glug of raw data, especially when you're getting blasted more of it every day. Where to store it, how to store it, how to index it so you can get at certain segments quickly, etc. Let's pretend that you've solved all of those and it's time to get to the meat of this exercise: figuring out when to buy. You write a little program that searches through your historical data looking for signs of business cycles in various sized companies and gives you the top five that you should buy and how long you should probably hold onto them. That list is *actionable information* that you created out of raw data that you can use to make some money. Maybe. Hopefully. If the world doesn't end. Again.

Ok, that's a pretty small example. Let's do something bigger. Let's pretend that you're Google. You have truck loads of cash just laying around waiting for you to do something with it. Hey, data centers are cool, why not build some new ones! But where?

You know immediate things, like where your users are coming from and where the bottlenecks in your network are that prevent them from looking at your sweet sweet ads. Now remember, you're Google. You have a large chunk of all accumulated human knowledge at your fingertips. In addition to that stuff that every good company would know, you also know, somewhere deep down in your giant cache, things like where the zoning codes are favorable, where you have private fiber connections to and from, where you can get cheap electricity, voting patterns, histories of war riots and famine for every location on the planet. Lots of data. So, you write some [Sawzall][] programs that go out and mine all this data and give you back likely locations, ranked by 10 year projected return on investment, and then you build at the top five places. Done. Easy.

In my admittedly limited time as a professional developer I've learned that probably close to 2/3 of my job is figuring out ways to suss out actionable information from vast quantities of low-level data. Be it displaying graphs or maps on a web page in the most understandable way, or trolling though a billion television remote clicks to determine who watched the Today Show this morning, it all boils down to providing some information to someone that they can act on.

In my personal life I need to have actionable information once in a while today. Before today [Calorific][] could only tell exactly what I ate in its entirety or daily totals. That's somewhat useful, but sometimes I want to know what my weekly averages are, or limit the daily or detail reports to just a couple of days. To address those issues I added `--begin` and `--end` filters which will limit any report to just that day range. Specifying just one will leave the other as an open range. Calorific parses dates using [DateTime::Format::Natural][], which means it does the right thing with basically any date format you throw at, including relative dates like `yesterday` or `3 days ago` . Also, I added a weekly report which prints daily averages for each week in the day range. This is the new default, which actually I'm not really sure about. Easy to change.

The next features on the docket are *goals*, which will let you set goal ranges for each base nutrient, an option to show you each day total or week average against the goal, and a summary report that shows you how much of each nutrient you've eaten today and how close you are to your goals. Stay tuned!

[1]:         http://www.activfinancial.com/
[2]:         http://www.interactivedata-rts.com/index.shtml
[3]:         http://www.dtniq.com/
[Calorific]: http://github.com/peterkeen/calorific
[Sawzall]:   http://labs.google.com/papers/sawzall.html
[DateTime::Format::Natural]: http://search.cpan.org/~schubiger/DateTime-Format-Natural-0.86/
