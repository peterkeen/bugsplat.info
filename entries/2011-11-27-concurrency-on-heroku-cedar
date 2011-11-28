Title: Concurrency on Heroku Cedar
Date:  2011-11-27 18:52:36
Id:    50b7f

I started a small product a few weeks ago called [FivePad][], a simple easy way to organize your apartment search. It's basically the big apartment search spreadsheet that you and me and everyone we know has made at least three times, except FivePad is way smarter.

The initial versions of FivePad did everything in the web request cycle, including sending email and pulling down web pages. The other day I was about to add my third in-cycle process when I threw up my arms in disgust. The time had come to integrate [resque][], a great little [redis][] based job queueing system. Except if I ran it the way Heroku makes things easy my costs would get a little bit out of control for a project that isn't making much money yet.

[FivePad]: https://www.fivepad.me
[redis]: http://redis.io
[resque]: https://github.com/defunkt/resque
[Heroku]: http://www.heroku.com
[multi-heroku]: http://blog.nofail.de/2011/07/heroku-cedar-background-jobs-for-free/
[heroku-unicorn]: http://michaelvanrooijen.com/articles/2011/06/01-more-concurrency-on-a-single-heroku-dyno-with-the-new-celadon-cedar-stack/
[Unicorn]: http://unicorn.bogomips.org/
[auto-scale]: http://verboselogging.com/2010/07/30/auto-scale-your-resque-workers-on-heroku
[remindlyo]: https://www.remindlyo.com

--fold--

### Backstory

First, a little backstory. Earlier in 2011 [Heroku][] announced their new cedar stack, which is a much more general platform for running webapps than their previous platforms. Cedar lets you describe the processes you want to run using a Procfile. Your processes can use one of a large selection of languages, but FivePad is all ruby. Here's what a Procfile can look like:

    web: bundle exec rails server
    worker: bundle exec rake resque:work QUEUE=*
    scheduler: bundle exec ruby ./config/clock.rb
    
This creates three different types of processes, `web`, `worker`, and `scheduler`. Heroku intends that you run one of each of these on three different dynos which all charge by the hour, but you get 750 hours free every month.

### Options

The official way to do this, of course, is to just spin up multiple dynos. Heroku makes this extremely easy:

    $ heroku scale web=2 worker=3
    
Bam. Done. Two web dynos and three worker dynos all running your code and talking to the same database. Gets to be a bit expensive for hobby/tiny projects, though.

Another option is to [run multiple Heroku apps][multi-heroku] with a shared database. This is decent, in that you get multiple full-powered dynos for free. However, it's kind of a pain to manage. You have to deploy to multiple git repos whenever you do a deploy and you have to make sure all of your environment variables are synced. I've tried it, it's not very much fun.

Yet another option is to [auto-scale your workers][auto-scale]. The basic idea here is that when a job comes in, the `resque` client triggers a worker to start up in another dyno, process the job, and then shut down when there are no more jobs left. I tried using this for a long time with [Remindlyo][] and experienced an annoying set of race conditions due to how long rails takes to start. Jobs would get lost and dropped kind of randomly.

### Cheating With Style

The system that I've devised for FivePad was inspired by [this post][heroku-unicorn] by Michael van Rooijen. There, he describes how best to run your rails app on [Unicorn][], a simple pre-forking rack server. Here's my `Procfile`:

    web: unicorn -p $PORT -c ./config/unicorn.rb
    
Not much to it. Here's what that `config/unicorn.rb` file looks like:

    worker_processes 3
    timeout 30
    
    @resque_pid = nil
    
    before_fork do |server, worker|
      @resque_pid ||= spawn("bundle exec rake " + \
      "resque:work QUEUES=scrape,geocode,distance,mailer")
    end
    
This starts out pretty simply. Three worker processes and a 30 second request timeout. But then there's that `before_fork` hook. This simply runs a specified `rake` task if and only if it hasn't been run before, immediately prior to forking off the next web worker. In this case, it runs the `resque:work` task, which is how `resque` processes jobs.

This will actually result in six processes in each web dyno:

 * 1 unicorn master
 * 3 unicorn web workers
 * 1 resque worker
 * 1 resque child worker when it actually is processing a job

This may be a bit much if your application is super heavy, but for FivePad it's working pretty well. Things are much faster now that all of the heavy duty stuff is done in the background, and scaling up to another dyno automatically scales the workers as well. One thing to consider in the future is to drop the web workers down to two and add another dyno, but I'm not going to do that until it actually has significant revenue coming in.

Another drawback of this is that if the worker falls over for some reason I'll have to restart the whole dyno, but the chances of that happening are pretty low. Resque forks off a child worker for every job it processes, which insulates the master worker from any problems with jobs. 

Anyway, for now this is how FivePad is running. Scaling up is will be simple in the future when it's necessary and I can control costs right now when that's really important. 
