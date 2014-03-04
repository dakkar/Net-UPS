#!perl
use strict;
use warnings;
use Test::Most;
use lib 't/lib';
use Test::Net::UPS;
use Test::Net::UPS::Factory;

my $ups = Test::Net::UPS::Factory::without_network;

$ups->prepare_test_from_file('t/data/rate-1-package');
$ups->prepare_test_from_file('t/data/rate-1-package');
$ups->prepare_test_from_file('t/data/rate-2-packages');
$ups->prepare_test_from_file('t/data/shop-1-package');
$ups->prepare_test_from_file('t/data/shop-2-packages');
$ups->prepare_test_from_file('t/data/address');

Test::Net::UPS::test_it($ups);

done_testing();
