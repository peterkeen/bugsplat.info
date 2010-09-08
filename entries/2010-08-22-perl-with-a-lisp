Title: Perl with a Lisp
Date:  2010-08-22 14:22:36
Id:    7497d
Hold:  1

Browsing around on [hacker news][hn] one day, I came across a [link][hn-micromanual] to a paper entitled "[A micro-manual for Lisp - Not the whole truth][micromanual]" by John McCarthy, the self-styled discoverer of Lisp. One commentor stated that they have been using this paper for awhile as a *code kata*, implementing it several times, each in a different language, in order to better learn that language. The other day I was pretty bored and decided that maybe doing that too would be a good way to learn something and aleviate said boredom. My first implementation is in perl, mostly because I don't want to have to learn a new language *and* lisp at the same time. The basic start is after the jump.

[hn]: http://news.ycombinator.com
[hn-micromanual]: http://news.ycombinator.com/item?id=1591112
[micromanual]: http://www.ee.ryerson.ca/~elf/pub/misc/micromanualLISP.pdf

--fold--

Building a lisp seems to center around two key decisions. First, how do you represent your core data structure? A two-element array? A struct? Something a little more complex? Second, what are your scoping rules. Lexical? Dynamic? Global? After that, everything else is gold plating. Substrate-langauge interop, how you represent scopes, how to get closures right, macros, etc, all can be determined later.

I've chosen to write this first implementation in perl. I know perl pretty well but more importantly I don't know lisp very well at all. I've done a little elisp hacking, but not much. I certainly don't know how all of the pieces fit together quite yet. This first post is really more about getting the fundamental data structure and list-manipulation routines and the reader down. Later posts will elaborate on `eval` and friends, as well as closures, scoping, and perl interop.

### Data Structure

Lisp represents most things fundamentally in terms of what's known as a *cons cell*. This is some sort of object that has two slots for other objects, be they primitives or other cons cells. Being a good little modern perl programmer, I've chosen to implement this as a small Moose-based [class][Cell]:

    package Cell;
    
    use Moose;

    use overload
        'bool' => sub { return !shift->is_nil() },
        'fallback' => 1
    ;
    
    has 'car'    => (is => 'rw');
    has 'cdr'    => (is => 'rw');
    has 'is_nil' => (is => 'ro', default => 0);
    
    1;

Using Moose, we define an object with two read-write slots named `car` and `cdr`. This is due entirely to historical precident: `car` is the first element in the pair, `cdr` is the second. `is_nil` is there to allow us to define a fixed `nil` value later on. The `overload` allows us to use a `Cell` in a boolean context. Anything that doesn't have `is_nil` set is `true`;

### Fundamental Functions

Now that we've got the data structure done, let's define a few [fundamental functions][Functions] to work with it.

    our $NIL = Cell->new(is_nil => 1);
    sub nil
    {
        return $NIL;
    }
    
    our $T = "t";
    sub t
    {
        return $T;
    }
    
    sub equal
    {
        my ($a, $b) = @_;
        return t if $a eq $b;
        return nil;
    }
    

Notice how `$NIL` is just hanging out there. It's the only Cell that will ever have `_is_nil` set. We return the reference to the singleton from the `nil` function. `t` is the opposite. We just return the atom `t`. `equal` exploits perl's built-in comparison operator `eq` to compare two things.

Now, the good stuff. List manipulation:

    sub cons
    {
        my ($thing, $list) = @_;
        return Cell->new(car => $thing, cdr => $list);
    }
    
    sub list
    {
        reduce { cons($b, $a) } (nil, reverse @_);
    }
    
    sub car
    {
        my $thing = shift;
        confess "Argument to car must be a list"
            unless ref($thing) && ref($thing) eq 'Cell';
        return defined($thing->car()) ? $thing->car() : nil;
    }
    
    sub cdr
    {
        my $thing = shift;
        confess "Argument to cdr must be a list"
            unless ref($thing) && ref($thing) eq 'Cell';
        return defined($thing->cdr()) ? $thing->cdr() : nil;
    }

`cons` creates new `Cell`s, setting their `car` and `cdr` as appropriate. The `list` function is a pure convenience thing to make setting up singly-linked lists easy. `car` and `cdr` do a small amount of error checking and call out to the given `Cell`'s `car()` and `cdr()` methods.

[Functions][] also defines some functions that will be used later, as well as some things that can walk lists and trees made from cons cells and do something with them. It implements a `list_string` function which will be imported as the `(print)` function, once we have symbol tables and function importing defined.

There are a bunch of tests for these functions in [01_list_manipulation.t][]. 

### Reader

Lisp's parser is referred to as the *reader*. Generally you interact with it using the `(read)` function, which pulls off of the input stream and returns the next parsed form as an AST. This reader consists of a hand-rolled recursive descent parser in [Read.pm][] that implements these constraints:

* Numbers consist only of numeric charcters and decimal points.
* Symbols start with `[a-zA-Z]` and can contain anything within that range, as well as numbers, the '`:`' character, underscores, and dashes.
* String literals start and end with the '`"`' character. Escaping is not implemented yet.
* Lists start with '`(`', end with '`)`', and contain one or more whitespace-delimited things.
* Whitespace is skipped.

This most basic of readers is only 113 lines of perl, but it can parse a string of characters that look like lisp and turn it into a tree of cons cells, ready to be evaluated. Tests and examples can be found in [02_read.t][].

Well, that's all for now. It's a good start, but doesn't really deal with any of the interesting bits yet. Next up: `(eval)`.

*What's your personal code kata? Have you written a lisp before? Have any tips for me?*

[Functions]: http://github.com/peterkeen/kata/blob/master/perl/lib/Functions.pm
[Cell]: http://github.com/peterkeen/kata/blob/master/perl/lib/Cell.pm
[Read.pm]: http://github.com/peterkeen/kata/blob/master/perl/lib/Read.pm
[01_list_manipulation.t]: http://github.com/peterkeen/kata/blob/master/perl/t/01_list_manipulation.t
[02_read.t]: http://github.com/peterkeen/kata/blob/master/perl/t/02_read.t