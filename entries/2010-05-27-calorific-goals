Title: Everyone Needs Goals
Date:  2010-05-27 20:37:00
Id:    8

Creating [actionable information][1] out of raw data is sometimes pretty simple, requiring only small changes. Of the few feature requests that I've received for [Calorific][], most (all) of them have been for goals. Always listen to the audience, that's my motto! With the latest version you can set up goals like this:

<pre>
- goals: 
    - kcal:    2200
    - protein: [ 100, 200 ]
    
- 2010-05-27 breakfast:
    - 1000 kcal
    - 25 protein

- 2010-05-27 lunch:
    - 850 kcal
    - 50 protein
    
- 2010-05-27 lunch:
    - 500 kcal
    - 50 protein
</pre>

This example is super simplified, of course, but you can see how it works. Creating an entry with the special name `goals` with one component for each nutrient you have a goal for. The value of each component is either a single number, which will be taken as a maximum, or a two element range.

Right now these are displayed by changing the color of the values on aggregate reports (daily and weekly). Red means "outside the range" and green means "inside the range".

<pre>
$ calorific
2010-05-27 &lt;total&gt;                <font color="red">2350</font> kcal
                                   <font color="green">125</font> prot
</pre>

Colors are done using [Term::ANSIColor][], which is included in core perl. Adding them was fairly easy, because of a simple function `colored`, which takes a scalar or an arrayref of scalars and a color argument and returns the scalar wrapped in the correct ANSI codes. Future display options could be displaying how much of each nutrient you have left for the day, maybe in a little progress bar type thing. Feature requests and comments are welcome, as always.

[1]:               2010-05-12-actionable-information.html
[Calorific]:       http://github.com/peterkeen/calorific
[Term::ANSIColor]: http://perldoc.perl.org/Term/ANSIColor.html