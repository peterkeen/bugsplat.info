#!/usr/bin/perl

use strict;
use warnings;
use lib './lib';

use Getopt::Long;
use App::Bugsplat::Publish;

GetOptions(
    "d|dry-run"   => \my $dry_run,
    "l|live"      => \my $live,
    "sync-path=s" => \(my $sync_path = 'ubuntu@bugsplat.info:/var/www/bugsplat.info'),
);

my $USAGE = "usage: $0 [--sync-path SYNC PATH] (--dry-run|--live)\n";

if (! ($dry_run || $live) ) {
    print STDERR $USAGE;
    exit 1;
}

my $top_dir = $ENV{PWD};

App::Bugsplat::Publish->new(
    entries_dir      => "$top_dir/entries",
    template_dir     => "$top_dir/templates",
    out_dir          => "$top_dir/out",
    static_dir       => "$top_dir/static",
    front_page_count => 5,
    remote_sync_path => $sync_path,
    is_live          => $live,
)->publish();

