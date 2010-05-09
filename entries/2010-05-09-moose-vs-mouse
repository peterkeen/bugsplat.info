Title: Moose vs Mouse and OOP in Perl
Date:  2010-05-09 08:00:00
Id:    4

After using [Calorific][] for a month two things have become very clear. First, I need to eat less. Holy crap do I need to eat less. I went on to [SparkPeople][] just to get an idea of what I *should* be eating, and it told me between 2300 and 2680 kcal. I haven't implemented averaging yet, but a little grep/awk magic tells me I'm averaging 2793 kcal per day. This is *too much*. So. One thing to work on.

Second, in the morning after I come back from lifting and sit down to enter my breakfast, I just add three lines to my calories file:
<pre>
- 2010-05-07 breakfast:
    - 1 workout breakfast (blues)
</pre>

and then type `calorific` in my shell, it takes *ages* to start up. Literally several seconds on a cold cache. I was pretty sure that this was due to the fact that I use [Moose][] to help me define the four classes that compose Calorific. Now, Moose is great. Before writing Calorific I had only used a really old version of [Class::MethodMaker][] or [Class::Struct][] to build classes. That or build them myself, which is always fun (FUN FACT blessed array refs are wicked fast if you can get away with them). Moose is sort of a revelation. In the simplest case, you can say
<pre>
package Foo::Bar;

use Moose;

has [qw/ baz blah frob /] => (is => 'rw');

1;
</pre>
And you have yourself a fully functional class with three properties with read-write accessors. Pretty snazzy. However, you can get way more advanced:
<pre>
package Calorific;

use Moose;

has 'filename' => (
    is       => 'ro',
    required => 1,
);

has 'recipes'  => (
    is      => 'ro',
    traits  => [ 'Hash' ],
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { {} },
    handles => {
        get_recipe => 'get',
        set_recipe => 'set',
    },
);

has 'entries' => (
    is      => 'rw',
    traits  => [ 'Array' ],
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub { [] },
    handles => {
        add_entries    => 'push',
        filter_entries => 'grep',
        num_entries    => 'count',
        all_entries    => 'elements',
        sorted_entries => 'sort',
    },
);

1;
</pre>

This is directly from Calorific. It defines three properties: a read-only simple scalar named `filename` which is required to be present in the call to new(), a `recipes` property which contains a hash ref and gets two accessors, `get_recipe` and `set_recipe`, which you call like this:
<pre>
$calorific_instance->set_recipe('foo', 'bar');
$calorific_instance->get_recipe('foo'); # returns 'bar'
</pre>

In addition, it sets up one more property named `entries` which contains an array ref and defines five accessors. There are actually more accessors defined than the code uses, but they're basically free so why not? You can see what they do and their calling conventions in the [Moose::Meta::Attribute::Native::Trait::Array][] docs. 

Ok, so Moose is great! Except, it's slow. Way slow. Wicked slow, especially on a groggy cache like my laptop has when I rudely wake it up in the morning and demand it actually do something for me for once. Geeze.

HOWEVER, there's a neat little project called [Mouse][], which has the lofty goal of emulating all of the sugar of Moose without any of the fat. Meaning, it doesn't pay nearly as large of a compile-time penalty that Moose does while retaining most of it's meta-y goodness. I ran one little command on the source tree yesterday evening and *bam*, just like that, everything was three times as fast.
<pre>
find . -name '*.pm' | xargs perl -pi -e 's/Moose/Mouse/g'
</pre>
Actually I had to install [MouseX::NativeTraits][] from CPAN before everything worked but that's just details.

Anyway, the moral of the story is that Moose is great and makes building classes really easy and all, but if you care about startup speed and not so much about delving into meta classes and such, Mouse should be your go-to class. And in fact, you don't have to make that choice. There's another project called [Any::Moose][], which will load Mouse unless you declare you want Moose, which can be set with an environment variable. Pretty neat.

[SparkPeople]:          http://www.sparkpeople.com/
[Calorific]:            http://github.com/peterkeen/calorific
[Moose]:                http://search.cpan.org/dist/Moose/
[Class::MethodMaker]:   http://search.cpan.org/dist/Class-MethodMaker/
[Class::Struct]:        http://search.cpan.org/~jesse/perl-5.12.0/lib/Class/Struct.pm
[Mouse]:                http://search.cpan.org/dist/Mouse/
[MouseX::NativeTraits]: http://search.cpan.org/dist/MouseX-NativeTraits/
[Any::Moose]:           http://search.cpan.org/~sartak/Any-Moose-0.12/lib/Any/Moose.pm
[Moose::Meta::Attribute::Native::Trait::Array]: http://search.cpan.org/~flora/Moose-1.03/lib/Moose/Meta/Attribute/Native/Trait/Array.pm
