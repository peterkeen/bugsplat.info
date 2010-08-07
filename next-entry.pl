#!/usr/bin/env perl

use strict;
use warnings;
use File::Slurp qw/ read_file write_file /;
use File::Find;

sub parse_one_file
{
    my $file = shift;
    my $stripped_file = $file . ".html";
    return () if -d $file;
    substr($stripped_file, 0, length("$ENV{PWD}/entries/"), '');
    my $contents = read_file($file);
    my $entry = parse_entry($contents);
    $entry->{Path} = $stripped_file;
    return $entry;
}

sub parse_entry
{
    my $raw_contents = shift;
    my ($headers, $content) = split(/\n\n/, $raw_contents, 2);
    my %headers = map { split(/:\s+/, $_, 2) } split(/\n/, $headers);
    return \%headers;
}

sub find_all_entries
{
    my @entries;
    File::Find::find(sub {
        return unless $_;
        return if $_ =~ /^[#\.]/;
        push @entries, parse_one_file($File::Find::name);
    }, "$ENV{PWD}/entries/");

    return \@entries;
}

my $max_id = 0;
for my $entry ( @{ find_all_entries() } ) {
    next unless $entry->{Id};
    next unless $entry->{Id} > $max_id;
    $max_id = $entry->{Id};
}
$max_id++;

my $title = qx{read -e -p "Title: " -s title; echo \$title};
chomp $title;

my $date = qx{date +'%Y-%m-%d'};
chomp $date;

my $datetime = qx{date +'%Y-%m-%d %H:%M:%S'};
chomp $datetime;

my $path = $date . '-' . lc($title);
$path =~ s/\s+/-/g;

write_file("entries/$path", <<HERE);
Title: $title
Date:  $datetime
Id:    $max_id


HERE

exec("/Applications/Emacs.app/Contents/MacOS/bin/emacsclient -n -t +5 entries/$path");
