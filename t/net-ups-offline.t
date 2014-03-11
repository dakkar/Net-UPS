#!perl
use strict;
use warnings;
use Test::Most;
use lib 't/lib';
use Test::Net::UPS;
use Test::Net::UPS::Factory;

my ($ups,$u) = Test::Net::UPS::Factory::without_network;

$u->prepare_test_from_file('t/data/rate-1-package');
$u->prepare_test_from_file('t/data/rate-1-package');
$u->prepare_test_from_file('t/data/rate-2-packages');
$u->prepare_test_from_file('t/data/shop-1-package');
$u->prepare_test_from_file('t/data/shop-2-packages');
$u->prepare_test_from_file('t/data/address');

Test::Net::UPS::test_it($ups);

done_testing();
