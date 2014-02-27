
BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::NoTabsTests 0.06

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Net/UPS.pm',
    'lib/Net/UPS/Address.pm',
    'lib/Net/UPS/ErrorHandler.pm',
    'lib/Net/UPS/Package.pm',
    'lib/Net/UPS/Rate.pm',
    'lib/Net/UPS/Service.pm',
    'lib/Net/UPS/Tutorial.pm'
);

notabs_ok($_) foreach @files;
done_testing;
