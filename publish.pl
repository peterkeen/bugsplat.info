#!/usr/bin/perl -w

use strict;

use Carp;
use File::Basename 'basename';
use File::Find;
use IO::File;
use Text::Markdown 'markdown';

use Getopt::Long;

GetOptions(
    "d|dry-run" => \my $dry_run,
);

my @entries;

File::Find::find(sub {
    return unless $_;
    return if $_ =~ /^[#\.]/;
    push @entries, parse_one_file($File::Find::name);
}, "$ENV{PWD}/entries/");

my @blog_entries = grep { defined $_->{Date} } @entries;
my @non_blog_entries = grep { !defined $_->{Date} } @entries;

my $blog_entries_html = "";
my $link_list_html = "";
my $archive_list_html = "";

my $count = 0;
for my $entry ( sort { $b->{Date} cmp $a->{Date} || $a->{Title} cmp $b->{Title}} @blog_entries ) {
    my $html = process_and_write_blog_entry($entry);
    if ($count++ < 10) {
        $blog_entries_html .= $html
    }
    $archive_list_html .= process_template('archive_entry', $entry);
}

for my $entry ( sort { $a->{Order} <=> $b->{Order} } @non_blog_entries ) {
    write_file_contents("$ENV{PWD}/out/" . $entry->{Path}, process_template(
        'main',
        {Content => process_template('entry', $entry)},
    ));
    $link_list_html .= process_template('link_list_entry', $entry);
}

print "Writing index\n";
write_file_contents(
    "$ENV{PWD}/out/index.html",
    process_template(
        'main',
        {
            Content => $blog_entries_html,
            LinkList => $link_list_html,
        }
    )
);

print "Writing archive\n";
write_file_contents(
    "$ENV{PWD}/out/archive.html",
    process_template(
        'main',
        {
            Content => $archive_list_html,
            LinkList => $link_list_html,
        }
    )
);

print "Copying static files\n";
File::Find::find(sub {
    return unless -f $File::Find::name;
    print $File::Find::name . "\n";
    write_file_contents(
        "$ENV{PWD}/out/" . basename($File::Find::name),
        read_file_contents($File::Find::name),
    );
}, "$ENV{PWD}/static/");

if ($dry_run) {
    print "Opening browser\n";
    system("open $ENV{PWD}/out/index.html");
} else {
    print "Pushing to live\n";
    system("scp -r out/* kodos:/var/web/bugsplat.info/");
    system("open http://bugsplat.info");
}

sub parse_one_file
{
    my $file = shift;
    my $stripped_file = $file . ".html";
    return () if -d $file;
    substr($stripped_file, 0, length("$ENV{PWD}/entries/"), '');
    my $entry = parse_entry(read_file_contents($file));
    $entry->{Path} = $stripped_file;
    return $entry;
}

sub parse_entry
{
    my ($contents, $filename) = shift;
    my ($headers, $content) = split(/\n\n/, $contents, 2);
    my %headers = map { split(/:\s+/, $_, 2) } split(/\n/, $headers);
    $content ||= "";
    $headers{Content} = markdown($content);
    return \%headers;
}

sub process_template
{
    my ($template, $values) = @_;
    my $content = read_file_contents("$ENV{PWD}/templates/$template.html");
    $content =~ s{\${([\w_]+)}}{
        my $out = "";
        if ($values->{$1}) {
            $out = $values->{$1};
        }
        $out;
    }ge;
    return $content;
}

sub process_and_write_blog_entry
{
    my $orig_entry = shift;
    my $entry = { %$orig_entry };

    print $entry->{Date} . " " . $entry->{Title} . " " . $entry->{Path} . "\n";

    $entry->{Date} = process_template('date', {Date => $entry->{Date}});

    my $entry_html = process_template('entry', $entry);
    my $page_html = process_template('main', {Content => $entry_html});

    my $filename = $ENV{PWD} . "/out/" . $entry->{Path};
    write_file_contents($filename, $page_html);

    return $entry_html;
}

sub read_file_contents
{
    my $filename = shift;
    my $fh = IO::File->new($filename, "r") or die "cannot open $filename: $!";
    return join('', $fh->getlines());
}

sub write_file_contents
{
    my ($filename, $contents) = @_;
    croak "no filename supplied" unless defined $filename;
    my $fh = IO::File->new($filename, "w+") or die "cannot open $filename: $!";
    $fh->print($contents);
    $fh->close();
}
