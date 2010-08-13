#!/usr/bin/perl -w
use strict;

use Carp;
use DateTime::Format::Natural;
use DateTime::Format::W3CDTF;
use File::Basename qw/ basename dirname /;
use File::Path qw/ make_path /;
use File::Find;
use File::Slurp qw/ read_file write_file /;
use File::Copy;
use Text::Markdown 'markdown';
use XML::Atom::SimpleFeed;

use Getopt::Long;

use constant FRONT_PAGE_COUNT => 5;

my $REMOTE_SCP_PATH = 'bugsplat.info:/var/web/bugsplat.info';
my $OUT_DIR = $ENV{PWD} . '/out';

GetOptions(
    "d|dry-run" => \my $dry_run,
    "l|live"  =>   \my $live,
);

if (! ($dry_run || $live) ) {
    print STDERR "one of either --dry-run or --live is needed\n";
    exit 1;
}

my $entries = find_all_entries();

clean_out_dir();
write_index_and_blog_entries($entries);
write_pages($entries);
write_archive($entries);
write_atom_feed($entries);
write_htaccess_file($entries);
copy_static_files();
sync_to_remote() unless $dry_run;
open_browser($dry_run);


sub internal_link_definitions($entries)
{
    my @internal_links;

    for my $entry ( $@entries ) {
        push @internal_links, process_template('internal_link', $entry);
    }
    return join("\n", @internal_links);
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

sub clean_out_dir
{
    system("rm -rf $OUT_DIR");
}

sub internal_link_definitions
{
    my $entries = shift;
    my @defs;
    for my $entry ( @$entries ) {
        push @defs, process_template('internal_link', $entry);
    }
    return join("\n", @defs);
}

sub write_index_and_blog_entries
{
    my $entries = shift;
    my $link_list = link_list($entries);
    my $count = 0;
    my $internal_links = internal_link_definitions($entries);

    $entry->{AfterContent} = $internal_links;
    $entry->{AfterPrefold} = $internal_links;

    my $blog_entries_html = '';
    for my $entry ( blog_entries($entries) ) {
        my $html = process_and_write_blog_entry($entry, $link_list);
        if ($count++ < FRONT_PAGE_COUNT) {
            $blog_entries_html .= $html
        }
    }

    process_and_write_file(
        'index.html',
        'main',
        ShortUrl => 'http://bugsplat.info',
        Content => $blog_entries_html . process_template('archive_link'),
        LinkList => $link_list,
    );
}

sub write_pages
{
    my $entries = shift;
    my $link_list = link_list($entries);

    for my $entry ( non_blog_entries($entries) ) {
        process_and_write_file(
            $entry->{Path},
            'main',
            ShortUrl => short_url($entry),
            Content => process_template('entry', { %$entry, PathSuffix => ''}),
            Title => $entry->{Title}. " - ",
            LinkList => $link_list,
        );
    }
}

sub write_archive
{
    my $entries = shift;
    my $link_list = link_list($entries);
    my $archive_html = "";

    for my $entry ( blog_entries($entries) ) {
        $archive_html .= process_template(
            'archive_entry',
            {
                Date  => short_date_for_entry($entry),
                Title => $entry->{Title},
                Path  => $entry->{Path},
             }
        );
    }

    process_and_write_file(
        "archive.html",
        'main',
        ShortUrl => 'http://bugsplat.info/archive.html',
        Title => 'Archive - ',
        Content => $archive_html,
        LinkList => $link_list,
    );
}

sub write_atom_feed
{
    my $atom = XML::Atom::SimpleFeed->new(
        title => 'Bugsplat',
        link  => 'http://bugsplat.info',
        author => { name => 'Pete Keen', email => 'pete@bugsplat.info' },
    );

    for my $entry ( blog_entries($entries) ) {
        $atom->add_entry(
            title     => $entry->{Title},
            link      => canonical_url($entry),
            id        => id_for_entry($entry),
            published => atom_date_for_entry($entry),
            updated   => atom_date_for_entry($entry),
            content   => $entry->{Content},
        );
    }

    mkdirs_and_write_file(
        "$OUT_DIR/index.xml",
        $atom->as_string(),
    );
}

sub canonical_url
{
    my $entry = shift;
    return 'http://bugsplat.info/' . $entry->{Path};
}

sub short_url
{
    my $entry = shift;
    return $entry->{Id} ?
        'http://bugsplat.info/' . $entry->{Id} :
        canonical_url($entry)
    ;

}

sub write_htaccess_file
{
    my $entries = shift;
    my $htaccess = <<HERE;
RewriteEngine on
HERE
    for my $entry ( blog_entries($entries) ) {
        $htaccess .= process_template('htaccess_rule', {
            Id      => $entry->{Id},
            FullUrl => canonical_url($entry),
        });
    }

    mkdirs_and_write_file("$OUT_DIR/.htaccess", $htaccess);
}

sub copy_static_files
{
    File::Find::find(sub {
        return unless -f $File::Find::name;
        print $File::Find::name . "\n";
        copy($File::Find::name, "$OUT_DIR/" . basename($File::Find::name));
    }, "$ENV{PWD}/static/");
}

sub sync_to_remote
{
    print "Pushing to live\n";
    system("rsync -av out/.htaccess $REMOTE_SCP_PATH");
    system("rsync -rav out/* $REMOTE_SCP_PATH");
}

sub open_browser
{
    my $dry_run = shift;
    my $path = $dry_run ? "$OUT_DIR/index.html" : 'http://bugsplat.info';
    system("open $path");
}

sub link_list
{
    my $entries = shift;
    my $html = "";
    for my $entry ( link_list_entries($entries) ) {
        $html .= process_template('link_list_entry', $entry);
    }
    return $html;
}

sub blog_entries
{
    my $entries = shift;
    return
        sort { $b->{Date} cmp $a->{Date} || $a->{Title} cmp $b->{Title} }
        grep { defined $_->{Date} && !should_hold($_) }
        @$entries;
}

sub should_hold
{
    my $entry = shift;
    return $live && defined $entry->{Hold}
}

sub non_blog_entries
{
    my $entries = shift;
    return
        sort { $a->{Title} cmp $b->{Title} }
        grep { !defined $_->{Date} && !should_hold($_) }
        @$entries;
}

sub link_list_entries
{
    my $entries = shift;
    return
        sort { $a->{Order} <=> $b->{Order} }
        grep { defined $_->{Order} && !defined $_->{Date} && !should_hold($_) }
        @$entries;
}

sub id_for_entry
{
    my ($entry) = @_;
    return 'tag:bugsplat.info,' . $entry->{Date} . ':' . $entry->{Id};
}

sub atom_date_for_entry
{
    my $date = shift->{Date}->clone;
    return DateTime::Format::W3CDTF->new()->format_datetime($date);
}

sub short_date_for_entry
{
    my $date = shift->{Date}->clone();
    $date->set_time_zone('America/Los_Angeles');
    return $date->format_cldr("YYYY-MM-dd");
}

sub parse_one_file
{
    $SIG{__DIE__} = sub { use Carp; confess @_ };

    my $file = shift;
    return () if -d $file;
    my $stripped_file = $file . ".html";
    substr($stripped_file, 0, length("$ENV{PWD}/entries/"), '');
    my $contents = read_file($file);
    my $entry = parse_entry($contents);

    $entry->{Name} = $file;
    $entry->{Path} = $stripped_file;

    return $entry;
}

sub parse_entry
{
    my $raw_contents = shift;
    my ($headers, $content) = split(/\n\n/, $raw_contents, 2);
    my ($prefold, $postfold) = split(/\n--fold--\n/, $content, 2);

    my %headers = map { split(/:\s+/, $_, 2) } split(/\n/, $headers);
    $postfold ||= "";

    $headers{Prefold} = sub { my $after = shift; markdown($prefold . "\n" . $after) };
    $headers{Content} = sub { my $after = shift; markdown($prefold . "\n" . $postfold . "\n" . $after) };

    if ($headers{Date}) {
        $headers{Date} = DateTime::Format::Natural->new(
            time_zone => 'America/Los_Angeles'
        )->parse_datetime($headers{Date});
        $headers{Date}->set_time_zone('UTC');
    }

    return \%headers;
}

sub process_template
{
    my ($template, $values) = @_;
    my $content = read_file("$ENV{PWD}/templates/$template.html");

    $content =~ s{\${([\w_]+)}}{
        my $out = "";
        if (defined $values->{$1}) {
            my $value = $values->{$1};
            my $after = $values->{"After$1"};
            $out = (ref($value) && ref($value) == 'CODEREF') ? $value->($after) : $value;
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
    my $link_list_html = shift;
    my $entry = { %$orig_entry };

    print $entry->{Date} . " " . $entry->{Title} . " " . $entry->{Path} . "\n";

    my $date = process_template('date', {Date => natural_date_for_entry($entry)});

    my $entry_html = process_template('entry', { %$entry, Date => $date, PathSuffix => '#disqus_thread'});
    my $comments_html = process_template('comments', {Dryrun => $dry_run ? 1 : 0});

    process_and_write_file(
        $entry->{Path},
        'main',
        ShortUrl => short_url($entry),
        Content => $entry_html . $comments_html,
        Title => $entry->{Title} . " - ",
        LinkList => $link_list_html,
    );

    return process_template(
        'short_entry',
        {
            %$entry,
            Date => $date,
            PathSuffix => '#disqus_thread',
            Content => $entry->{Prefold},
        }
    );
}

sub process_and_write_file
{
    my ($page_name, $template_name, %params) = @_;
    my $content = process_template($template_name, \%params);
    mkdirs_and_write_file("$OUT_DIR/$page_name", $content);
    return $content;
}

sub mkdirs_and_write_file
{
    my ($filename, $content) = @_;
    my $dirs = dirname($filename);
    make_path($dirs);
    write_file($filename, $content);
}
