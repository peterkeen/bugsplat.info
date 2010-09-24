Title: ProcLaunch v1.0
Date:  2010-09-23 19:39:47
Id:    0d5b3

I kind of started [ProcLaunch][] as a lark. Can I actually do better than the existing user space process managers? It turns out that at least a few people think so. I've gotten a ton of great feedback from [thijsterlouw](http://github.com/thijsterlouw), who actually filed bug reports and helped me work through a bunch of issues. ProcLaunch even has some tests now!

As of today, I'm releasing ProcLaunch v1.0, which you can download from the [github downloads page][]. Interesting changes from the initial version:

* Moved to an explicit state machine

    In the first version there were a lot of edge cases where proclaunch would have a seemingly random sleep, or some other weird thing. I've removed all of the edge cases by creating an explicit state machine. Profiles have a `_status()` attribute, which is always one of `stopped`, `starting`, `running`, or `stopping`. The only `sleep()` is at the end of the main loop.

    The main motivation for this change is because the old version was just plain bad design. Every iteration of the main loop woule create a whole new set of `Profile` objects, overwriting the old list. Awp, but what happens to profiles that should stop? Let's keep track of their pids and keep trying to kill them over and over until they finally die. But what happens if proclaunch dies before those pids die? Do they just live forever, the eternal zombies of a daemon gone wrong?

    The new design eliminates both the repeated kill and the overwriting. Now, profiles are kept in a hash keyed on name and are never replaced after creation. Profiles that get stopped are put in the `stopping` state, which will check up on the pid every second until it finally dies, then moved to `stopped`, ready to be restarted.

* Improved logging

    Log lines have a static format: `<Timestamp> <Log Level> <Tag> <Message>`. `<Tag>` is either `ProcLaunch` or the name of the profile. If a message mentiones a pid, it will always be stated as `pid <PID>`. This change should make it easier to grep through the logs and automatically parse them for monitoring through nagios or what-have-you. 

Please check it out and beat it up. If you notice any issues, don't hesitate to [submit an issue][proclaunch issues] or [email me](mailto:pete@bugsplat.info), or just leave a comment below.

[ProcLaunch]: http://github.com/peterkeen/proclaunch
[github downloads page]: http://github.com/peterkeen/proclaunch/downloads
[proclaunch issues]: http://github.com/peterkeen/proclaunch/issues
