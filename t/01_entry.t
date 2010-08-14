use Test::More tests => 15;

BEGIN { use_ok('App::Bugsplat::Entry'); }

my $blog_entry = <<'HERE';
Title: Test Blog
Id:    test
Date:  2010-08-13 08:37

Prefold content

--fold--

Postfold content
HERE

my $entry = App::Bugsplat::Entry->new(raw => $blog_entry, filename => '/foo/bar/2010-08-13-test-blog');

ok $entry, "can build an entry object";
is $entry->filename(), "/foo/bar/2010-08-13-test-blog", "Sets name from args";
is $entry->Name(),     "2010-08-13-test-blog",          "Extracts name from filename";
is $entry->Path(),     "2010-08-13-test-blog.html",     "Constructs path";
is $entry->content(), <<HERE, "Combines prefold and postfold";
Prefold content

Postfold content
HERE

is $entry->prefold(), <<HERE, "Extracts prefold";
Prefold content
HERE

is $entry->NaturalDate(), "Friday, 13 August 2010 around 8 o'clock AM", "Natrual date format";
is $entry->ShortDate(),   "2010-08-13", "Short date format";
is $entry->atom_date(),   "2010-08-13T15:37:00Z", "Atom date format";
is $entry->atom_id(),     "tag:bugsplat.info,2010-08-13T15:37:00:test", "Atom ID";
is $entry->ContentHtml(), <<HERE, "Builds html";
<p>Prefold content</p>

<p>Postfold content</p>
HERE

is $entry->PrefoldHtml(), <<HERE, "Builds prefold html";
<p>Prefold content</p>
HERE

is $entry->ShortUrl(),     'http://bugsplat.info/test', "Builds short url";
is $entry->CanonicalUrl(), 'http://bugsplat.info/2010-08-13-test-blog.html', "Builds canonical url";
