package App::Bugsplat::Entry;

use Moose;
use File::Basename qw/ basename /;
use File::Slurp qw/ read_file /;
use DateTime::Format::Natural;
use DateTime::Format::W3CDTF;
use Carp;

use Text::Markdown 'markdown';

has raw      => (is => 'ro', required   => 1);
has filename => (is => 'ro', required   => 1);
has content  => (is => 'ro', lazy_build => 1);
has prefold  => (is => 'ro', lazy_build => 1);
has _raw     => (is => 'ro', lazy_build => 1);
has _headers => (
    is => 'ro',
    isa => 'HashRef',
    auto_deref => 1,
    lazy_build => 1
);

sub parse
{
    my ($class, $filename) = @_;
    return () unless -e $filename;
    my $contents = read_file($filename);
    return $class->new(filename => $filename, raw => $contents);
}

sub _header_allowed
{
    my ($self, $header) = @_;
    my %legal_headers = map { $_ => 1 } qw(
        Date
        Path
        Title
        Id
        Name
        Order
        Hold
    );

    return $legal_headers{$header};
}

sub _build__headers
{
    $SIG{__DIE__} = sub { use Carp; confess @_ };
    my $self = shift;
    my ($headers) = $self->_split_raw();

    my %headers = map { split (/:\s+/, $_, 2) } split(/\n/, $headers);

    if ($headers{Date}) {
        $headers{Date} = DateTime::Format::Natural->new(
            time_zone => 'America/Los_Angeles'
        )->parse_datetime($headers{Date});
        $headers{Date}->set_time_zone('UTC');
    }

    my $filename = basename($self->filename());
    my $html_path = $filename . ".html";
    $headers{Name} = $filename;
    $headers{Path} = $html_path;

    return \%headers;
}

sub _build_content
{
    my $self = shift;
    my (undef, $prefold, $postfold) = $self->_split_raw();
    return join("", $prefold, ($postfold || ""));
}

sub _build_prefold
{
    my $self = shift;
    my (undef, $prefold) = $self->_split_raw();
    return $prefold;
}

sub _split_raw
{
    my $self = shift;
    my ($headers, $content) = split(/\n\n/, $self->raw(), 2);
    my ($prefold, $postfold) = split(/\n--fold--\n/, $content, 2);
    return ($headers, $prefold, $postfold);
}

sub NaturalDate
{
    my $self = shift;
    return "" unless $self->Date();
    my $date = $self->Date()->clone();
    $date->set_time_zone('America/Los_Angeles');
    return $date->format_cldr("EEEE, dd LLLL YYYY 'around' h 'o''clock' a");
}

sub ShortDate
{
    my $self = shift;
    return "" unless $self->Date();
    my $date = $self->Date()->clone();
    $date->set_time_zone("America/Los_Angeles");
    return $date->format_cldr("YYYY-MM-dd");
}

sub atom_date
{
    my $self = shift;
    return "" unless $self->Date();
    my $date = $self->Date()->clone();
    return DateTime::Format::W3CDTF->new()->format_datetime($date);
}

sub atom_id
{
    my $self = shift;
    my $date = $self->Date()->clone();
    my $id   = $self->Id();
    return join('', 'tag:bugsplat.info,', $date, ':', $id);
}

sub ContentHtml
{
    my ($self, $after) = @_;
    $after ||= "";
    return markdown($self->content() . "\n" . $after);
}

sub PrefoldHtml
{
    my ($self, $after) = @_;
    $after ||= "";
    return markdown($self->prefold() . "\n" . $after);
}

sub ShortUrl
{
    my $self = shift;
    return $self->Id() ?
        'http://bugsplat.info/' . $self->Id() :
        $self->CanonicalUrl();
}

sub CanonicalUrl
{
    my $self = shift;
    return 'http://bugsplat.info/' . $self->Path();
}

sub should_hold
{
    my ($self, $live) = shift;
    return $live && $self->Hold();
}

sub is_blog_entry
{
    my $self = shift;
    return $self->Date();
}

sub view
{
    my ($self, $args, @methods) = @_;

    if (ref($args) ne 'ARRAY') {
        unshift @methods, $args;
        $args = [];
    }

    return map {
        $_ => $self->$_(@$args);
    } @methods;
}

sub AUTOLOAD
{
    my $self = shift;
    my ($name) = our $AUTOLOAD =~ /::(\w+)$/;
    croak "'$name' is neither a method nor a valid header"
        unless $self->_header_allowed($name);

    return $self->_headers()->{$name};
}

no Moose;
__PACKAGE__->meta()->make_immutable();

1;
