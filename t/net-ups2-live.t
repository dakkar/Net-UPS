#!perl
use strict;
use warnings;
use Test::Most;
use lib 't/lib';
use Test::Net::UPS2;
use Test::Net::UPS2::Factory;

my $ups = Test::Net::UPS2::Factory::from_config;

Test::Net::UPS2::test_it($ups);

done_testing();
