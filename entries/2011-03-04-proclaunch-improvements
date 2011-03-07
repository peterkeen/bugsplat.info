Title: ProcLaunch Improvements and v1.1
Date:  2011-03-04 16:31:23
Id:    61d35

ProcLaunch has learned a bunch of new things lately. I've fixed a few bugs and implemented a few new features, including:

 * A `--log-level` option, so you can set a level other than `DEBUG`
 * Kill profiles that don't exist
 * Instead of killing the process and restarting, proclaunch can send it a signal using the `reload` file
 * Instead of always sending `SIGTERM`, the `stop_signal` file can contain the name of a signal to send when proclaunch wants to stop a profile
 * Pid files are properly cleaned up after processes that don't do it themselves
 * You won't get two copies of proclaunch if one is already running as root

Get version 1.1 from [github][proclaunch]! Thanks a bunch to Matt, who hunted down the bugs and helped me figure out the features.

(Also, I added [highlight.js][] syntax highlighting. Hope you like it!)

[proclaunch]:   http://github.com/peterkeen/proclaunch
[highlight.js]: http://softwaremaniacs.org/soft/highlight/en/
