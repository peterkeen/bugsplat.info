use Test::More tests => 4;

use File::Slurp qw/ write_file /;
use File::Temp qw/ tempdir /;

BEGIN { use_ok('App::Bugsplat::Publish'); }

my $dir = tempdir(CLEANUP => 1);
mkdir "$dir/entries";
mkdir "$dir/static";
mkdir "$dir/templates";

write_file("$dir/templates/simple.html", <<HERE);
Simple Template
{{Value}}
{{Value2}}
HERE

write_file("$dir/templates/complex.html", <<HERE);
Complex Template
{{#Values simple}}
HERE

my $app = App::Bugsplat::Publish->new(
    entries_dir      => "$dir/entries",
    static_dir       => "$dir/static",
    template_dir     => "$dir/templates",
    out_dir          => "$dir/out",
    front_page_count => 5,
    remote_sync_path => 'bugsplat.info:/var/web/test',
    is_live          => 0
);

ok $app, "Compiles";

is $app->process_template('simple', { Value => 'hi', Value2 => 'there' }), <<HERE, "Process simple template";
Simple Template
hi
there
HERE

is $app->process_template(
    'complex',
    { Values => [
        {
            Value => 'hi',
            Value2 => 'there'
        },
        {
            Value => 'bug',
            Value2 => 'splat',
        }
    ]}), <<HERE, "Process more complex template";
Complex Template
Simple Template
hi
there
Simple Template
bug
splat

HERE
