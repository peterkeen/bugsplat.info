Title: Yet Another Static HTML Blog
Date:  2010-03-28 22:15:00
Id:    1

I'm a strict believer in learning by doing. It's how I learn best. In the spirit of learning, then, here's how I built the engine that powers this blog.

Right away I decided that there's no point in having a database to back this thing. The only useful thing that a database brings to the table is comments, and those are way more hassle than they're worth. Better to leave the comments at [reddit](http://reddit.com) or [hacker news](http://news.ycombinator.com), where they already know how to deal with spam. Not having to worry about a database freed me up to worry about more important things, like how to put text on the screen. I'm most familiar with [perl](http://www.perl.org) at the moment so I decided that the best way to build it would be a client-side script that generates some static html.

Current features:

* Absolutely no database
* Generates fully static html
* Automatically ships it to my server
* A really cheesy template system because I didn't want to learn [Template::Toolkit](http://search.cpan.org/dist/Template::Toolkit) just yet
* Archives for everything, and only show the last 10 entries on the front page
* Static pages (although currently there aren't any)
* Markdown parsing for entries

If you want to see the source for it (including all the entries), it's on [github](http://github.com/peterkeen/bugsplat.info), but I warn you it's kind of lame. The template system in particular is not really what I want it to be yet. It's non-recursive, so [publish.pl](http://github.com/peterkeen/bugsplat.info/blob/master/publish.pl) basically acts like the top-level template. I'll probably end up converting it to [Template::Toolkit](http://search.cpan.org/dist/Template::Toolkit) at some point.

