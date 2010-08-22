package App::Bugsplat::Publish;

use strict;
use warnings;

use Moose;

use App::Bugsplat::Entry;
use XML::Atom::SimpleFeed;

use File::Slurp    qw/ read_file write_file /;
use File::Path     qw/ make_path            /;
use File::Find     qw/ find                 /;
use File::Basename qw/ basename dirname     /;
use File::Copy     qw/ copy                 /;

has entries_dir      => (is => 'ro', required => 1);
has template_dir     => (is => 'ro', required => 1);
has static_dir       => (is => 'ro', required => 1);
has out_dir          => (is => 'ro', required => 1);
has front_page_count => (is => 'ro', required => 1);
has remote_sync_path => (is => 'ro', required => 1);
has is_live          => (is => 'ro', required => 1);
has _entries => (
    is         => 'rw',
    isa        => 'ArrayRef',
    auto_deref => 1,
);

sub BUILD
{
    my $self = shift;
    my @entries;

    find(sub {
        return unless $_;
        return if $_ =~ /^[#\.]/;
        push @entries, App::Bugsplat::Entry->parse($File::Find::name);
    }, $self->entries_dir());

    $self->_entries(\@entries);
}

sub publish
{
    my $self = shift;
    $self->write_index();
    $self->write_pages();
    $self->write_archive();
    $self->write_atom_feed();
    $self->write_htaccess_file();
    $self->copy_static_files();

    $self->sync_to_remote() if $self->is_live();

    $self->open_browser();
}

sub process_template
{
    my ($self, $template_name, $view) = @_;

    my $content = read_file($self->template_dir() . "/$template_name.html");

    $content =~ s{{{(#)?([A-Za-z0-9_]+)(\s+([A-Za-z0-9_]+))?}}}{
        my $out = "";
        my $modifier = $1 || "";
        my $key = $2;
        my $next_template = $4 || "";

        if (defined $view->{$key}) {

            if ($modifier eq '#') {
                $out = join("", map {
                    $self->process_template($next_template, $_)
                } @{ $view->{$key} });
            } else {
                $out = $view->{$key};
            }
        }

        $out;
    }ge;

    return $content;
}

sub internal_links
{
    my ($self) = shift;

    return $self->process_template(
        'internal_links', {
            Entries => [ map {
                { $_->view(qw/ Name Path Title Id /) }
            } $self->_entries() ]
        }
    );
}

sub link_list_entries
{
    my $self = shift;
    return
        sort { $a->Order() <=> $b->Order() }
        grep { defined $_->Order() && !defined $_->Date() && !$_->should_hold($self->is_live()) }
        $self->_entries();
}

sub blog_entries
{
    my $self = shift;
    return
        sort { $b->Date() cmp $a->Date() || $a->Title() cmp $b->Title() }
        grep { $_->is_blog_entry() && !$_->should_hold($self->is_live()) }
        $self->_entries();
}

sub non_blog_entries
{
    my $self = shift;
    return
        sort { $a->Title() cmp $b->Title() }
        grep { !$_->is_blog_entry() && !$_->should_hold($self->is_live()) }
        $self->_entries();
}

sub link_list
{
    my $self = shift;

    $self->process_template(
        'link_list', {
            Entries => [ map {
                { $_->view(qw/ Path Title /) }
            } $self->link_list_entries() ]
        }
    );
}

sub write_index
{
    my $self = shift;
    my $internal_links = $self->internal_links();

    my @entries = $self->blog_entries();

    my $count = $self->front_page_count() - 1;
    $self->write_page('index.html', {
        Content => $self->process_template(
            'index', {
                Entries => [ map {
                    { $_->view(qw/
                        Path
                        Title
                        NaturalDate
                      /),
                      ContentHtml => $_->PrefoldHtml($internal_links),
                      TrailingHtml => $self->process_template(
                          'comments_link',
                          {
                              Path => $_->Path(),
                              PathSuffix => '#disqus_thread',
                          }
                      ),
                    }
                } grep { $_ } @entries[0..$count] ]
            }
        ),
        LinkList => $self->link_list(),
        Title => '',
        ShortUrl => 'http://bugsplat.info',
    });
}

sub write_archive
{
    my $self = shift;
    my $internal_links = $self->internal_links();

    my @entries = $self->blog_entries();

    my $count = $self->front_page_count() - 1;
    $self->write_page('archive.html', {
        Content => $self->process_template(
            'archive', {
                Entries => [ map {
                    { $_->view(qw/
                        Path
                        Title
                        ShortDate
                      /),
                    }
                } @entries ]
            }
        ),
        LinkList => $self->link_list(),
        Title => 'Archive -',
        ShortUrl => 'http://bugsplat.info/archive.html',
    });
}

sub write_atom_feed
{
    my $self = shift;

    my $atom = XML::Atom::SimpleFeed->new(
        title => 'Bugsplat',
        link  => 'http://bugsplat.info',
        author => { name => 'Pete Keen', email => 'pete@bugsplat.info' },
    );

    for my $entry ( $self->blog_entries() ) {
        $atom->add_entry(
            title     => $entry->Title(),
            link      => $entry->CanonicalUrl(),
            id        => $entry->Id(),
            published => $entry->atom_date(),
            updated   => $entry->atom_date(),
            content   => $entry->ContentHtml(),
        );
    }

    $self->write_to_out_dir('index.xml', $atom->as_string());
}

sub write_pages
{
    my $self = shift;
    my $internal_links = $self->internal_links();

    for my $entry ( $self->_entries() ) {
        $self->write_page($entry->Path(), {
            Content => $self->process_template(
                'entry', {
                    $entry->view(qw/
                        Path
                        NaturalDate
                        ContentHtml
                        Title
                    /),
                    TrailingHtml => $entry->is_blog_entry() ? $self->process_template(
                        'comments',
                        {
                            Dryrun => !$self->is_live()
                        }
                    ) : "",
                }
            ),
            LinkList => $self->link_list(),
            Title => $entry->Title() . ' -',
            ShortUrl => $entry->ShortUrl(),
        });
    }
}

sub write_htaccess_file
{
    my $self = shift;
    $self->write_to_out_dir('.htaccess', $self->process_template(
        'htaccess',
        {
            Rules => [
                map { { $_->view(qw/ CanonicalUrl Id /) } } $self->_entries()
            ],
        }
    ));
}

sub copy_static_files
{
    my $self = shift;
    File::Find::find(sub {
        return unless -f $File::Find::name;
        print STDERR "Copying " . $File::Find::name . "\n";
        copy($File::Find::name, $self->out_dir() . "/" . basename($File::Find::name));
    }, $self->static_dir());
}

sub sync_to_remote
{
    my $self = shift;

    my $out = $self->out_dir();
    my $remote_sync_path = $self->remote_sync_path();
    system("rsync -av $out/.htaccess $remote_sync_path");
    system("rsync -av $out/* $remote_sync_path");
}

sub open_browser
{
    my $self = shift;
    my $path = $self->is_live() ? 'http://bugsplat.info' : $self->out_dir() . "/index.html";
    system("open $path");
}

sub write_page
{
    my ($self, $pagename, $view) = @_;
    $self->write_to_out_dir($pagename, $self->process_template('main', $view));
}

sub write_to_out_dir
{
    my ($self, $filename, $content) = @_;
    my $fullpath = $self->out_dir() . "/" . $filename;
    my $dirs = dirname($fullpath);
    make_path($dirs);
    print STDERR "writing $fullpath\n";
    write_file($fullpath, $content);
}

no Moose;
__PACKAGE__->meta()->make_immutable();

1;
