#!perl
use strict;
use warnings;
use Test::Most;
use lib 't/lib';
use Test::Net::UPS2;
use Test::Net::Async::Webservice::UPS::Factory;

my ($ups,$u) = Test::Net::Async::Webservice::UPS::Factory::without_network;

$u->prepare_test_from_file('t/data/rate-1-package');
$u->prepare_test_from_file('t/data/rate-1-package');
$u->prepare_test_from_file('t/data/rate-2-packages');
$u->prepare_test_from_file('t/data/shop-1-package');
$u->prepare_test_from_file('t/data/shop-2-packages');
$u->prepare_test_from_file('t/data/address');

Test::Net::UPS2::test_it($ups);

done_testing();
