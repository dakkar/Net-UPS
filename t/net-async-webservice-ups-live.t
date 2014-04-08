#!perl
use strict;
use warnings;
use Test::Most;
use lib 't/lib';
use Test::Net::UPS2;
use Test::Net::Async::Webservice::UPS::Factory;

my ($ups,$loop) = Test::Net::Async::Webservice::UPS::Factory::from_config;

Test::Net::UPS2::test_it($ups);

done_testing();
