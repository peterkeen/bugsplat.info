#!/usr/bin/perl -w

use strict;

use Carp;
use DateTime::Format::Natural;
use DateTime::Format::W3CDTF;
use File::Basename 'basename';
use File::Find;
use File::Slurp qw/ read_file write_file /;
use File::Copy;
use Text::Markdown 'markdown';
use XML::Atom::SimpleFeed;

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

my $atom = XML::Atom::SimpleFeed->new(
    title => 'Bugsplat',
    link  => 'http://bugsplat.info',
    author => { name => 'Pete Keen', email => 'pete@bugsplat.info' },
);

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
    $atom->add_entry(
        title     => $entry->{Title},
        link      => 'http://bugsplat.info/' . $entry->{Path},
        id        => id_for_entry($entry, $count),
        published => atom_date_for_entry($entry),
        updated   => atom_date_for_entry($entry),
        content   => $entry->{Content},
    );
}

for my $entry ( sort { $a->{Order} <=> $b->{Order} } @non_blog_entries ) {
    write_file("$ENV{PWD}/out/" . $entry->{Path}, process_template(
        'main',
        {Content => process_template('entry', $entry), Title => $entry->{Title}. " - "},
    ));
    $link_list_html .= process_template('link_list_entry', $entry);
}

print "Writing index\n";
write_file(
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
write_file(
    "$ENV{PWD}/out/archive.html",
    process_template(
        'main',
        {
            Content => $archive_list_html,
            LinkList => $link_list_html,
        }
    )
);

print "Writing atom feed\n";
write_file(
    "$ENV{PWD}/out/index.xml",
    $atom->as_string(),
);

print "Copying static files\n";

File::Find::find(sub {
    return unless -f $File::Find::name;
    print $File::Find::name . "\n";
    copy($File::Find::name, "$ENV{PWD}/out/" . basename($File::Find::name));
}, "$ENV{PWD}/static/");

if ($dry_run) {
    print "Opening browser\n";
    system("open $ENV{PWD}/out/index.html");
} else {
    print "Pushing to live\n";
    system("scp -r out/* kodos:/var/web/bugsplat.info/");
    system("open http://bugsplat.info");
}

sub id_for_entry
{
    my ($entry, $number) = @_;
    return 'tag:bugsplat.info,' . $entry->{Date} . ':' . $number;
}

sub atom_date_for_entry
{
    my $date = shift->{Date}->clone;
    return DateTime::Format::W3CDTF->new()->format_datetime($date);
}

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
    $content ||= "";
    $headers{Content} = markdown($content);
    $headers{Date} = DateTime::Format::Natural->new(
        time_zone => 'America/Los_Angeles'
    )->parse_datetime($headers{Date});
    $headers{Date}->set_time_zone('UTC');
    return \%headers;
}

sub process_template
{
    my ($template, $values) = @_;
    my $content = read_file("$ENV{PWD}/templates/$template.html");
    $content =~ s{\${([\w_]+)}}{
        my $out = "";
        if (defined $values->{$1}) {
            $out = $values->{$1};
        }
        $out;
    }ge;
    return $content;
}

sub natural_date_for_entry
{
    my $date = shift->{Date}->clone();
    $date->set_time_zone('America/Los_Angeles');
    return $date->format_cldr("EEEE, dd LLLL YYYY 'around' h 'o''clock' a");
}

sub process_and_write_blog_entry
{
    my $orig_entry = shift;
    my $entry = { %$orig_entry };

    print $entry->{Date} . " " . $entry->{Title} . " " . $entry->{Path} . "\n";

    my $date = process_template('date', {Date => natural_date_for_entry($entry)});

    my $entry_html = process_template('entry', { %$entry, Date => $date});
    my $comments_html = process_template('comments', {Dryrun => $dry_run ? 1 : 0});
    my $page_html = process_template('main', {Content => $entry_html . $comments_html, Title => $entry->{Title} . " - "});

    my $filename = $ENV{PWD} . "/out/" . $entry->{Path};
    write_file($filename, $page_html);

    return $entry_html;
}
