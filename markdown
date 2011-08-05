#!/usr/bin/perl -w

use strict;
use Text::Markdown 'markdown';

local $/ = undef;
my $text = <>;

print markdown($text);
