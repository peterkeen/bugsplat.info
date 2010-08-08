#!/usr/bin/env perl

use strict;
use warnings;
use File::Slurp qw/ write_file /;

my $title = qx{read -e -p "Title: " -s title; echo \$title};
chomp $title;

my $date = qx{date +'%Y-%m-%d'};
chomp $date;

my $datetime = qx{date +'%Y-%m-%d %H:%M:%S'};
chomp $datetime;

my $path = $date . '-' . lc($title);
$path =~ s/\s+/-/g;

my $id = substr(qx{echo $path | shasum}, 0, 5);

write_file("entries/$path", <<HERE);
Title: $title
Date:  $datetime
Id:    $id


HERE

exec("/Applications/Emacs.app/Contents/MacOS/bin/emacsclient -n -t +5 entries/$path");
