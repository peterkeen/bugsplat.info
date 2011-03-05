Title: I Soldered Something!
Date:  2011-02-15 17:57:31
Id:    91714

The [Arduino](http://arduino.cc) is a cool little development board, actually a series of them, that make it a snap to get up and running with embedded development. I've wanted to get my hands on one for awhile but I haven't really had an application. That is, I didn't until I saw this:

<iframe title="YouTube video player" width="580" height="390" src="http://www.youtube.com/embed/sHAa2H-_3yo" frameborder="0" allowfullscreen></iframe>

--fold--

And then I did some research and found this: 

<iframe title="YouTube video player" width="580" height="390" src="http://www.youtube.com/embed/hkMuKHYwfbQ" frameborder="0" allowfullscreen></iframe>

This is an r/c quadcopter, a four bladed helicopter that uses an Arduino running the [MultiWii][] software wired up to some knock-off Wii sensors to stabilize itself. The concept is similar to an F-22 or F-117, in that the thing is completely unstable and would probably fall out of the sky without computer control. This is then connected to a four channel r/c receiver, controlled by a normal r/c transmitter.

So.

Cool.

Of course I immediately started scheming to get one of these up and running. The biggest problem was that I had no tools, nor an Arduino, nor any r/c equipment, nor materials to put this thing together. Naturally, I turned to [SparkFun][] to set me up. They're a great online store that has all kinds of useful bits, including most everything electronics-wise that I'll need to get this project off the ground.

The box arrived today!

<a href="http://www.flickr.com/photos/zrail/5449798142/" title="The box is here! by zrail, on Flickr"><img src="http://farm6.static.flickr.com/5051/5449798142_0587cc63e2.jpg" width="500" height="374" alt="The box is here!" /></a>

And here's what was inside it:

<a href="http://www.flickr.com/photos/zrail/5449777782/" title="Order Contents by zrail, on Flickr"><img src="http://farm6.static.flickr.com/5299/5449777782_5f153c6533.jpg" width="500" height="374" alt="Order Contents" /></a>

(click the picture to see Flickr notes)

Basically I needed everything, so I got a cheap but solid soldering iron, solder, wires, headers, a brass "sponge" for cleaning the iron, and of course a pair of [Arduino Pro Mini 16MHz 5v][arduinopromini] as well as the appropriate programming cable.

After unboxing I installed the Arduino software, the USB driver, and tried getting the simple blink example to install on one of the Arduinos without soldering on some headers. Wouldn't program very reliably, so I broke down and actually heated up the iron and melted some stuff. Here's the result:

<a href="http://www.flickr.com/photos/zrail/5449776654/" title="Arudino Pro Mini up and running by zrail, on Flickr"><img src="http://farm6.static.flickr.com/5058/5449776654_43c8491b4a.jpg" width="500" height="374" alt="Arudino Pro Mini up and running" /></a>

Most of the joints are fine, but TX0 didn't get much solder through the hole so I'm going to have to watch it. In any case, it works. I got the blink example working and then wrote up a stupid little S-O-S blinking program and installed it. Pretty lame in the grand scheme of things, but I got it all running, including the soldering, in less than an hour. Extremely gratifying and a great start.

Now to buy sensors, motors, propellers, r/c equipment, and batteries, build the frame, etc etc. I'm thinking strongly about refactoring and rewriting large chunks of MultiWii, but that will come after I get it flying with the stock code.

[Arduino]:        http://arduino.cc
[MultiWii]:       http://www.multiwii.com/
[SparkFun]:       http://www.sparkfun.com/
[arduinopromini]: http://www.sparkfun.com/products/9218

