#!perl
use strict;
use warnings;
use Test::Most;
use Test::Fatal;
use lib 't/lib';
use Test::Net::UPS2;
use Test::Net::UPS2::Factory;

my ($ups,$u) = Test::Net::UPS2::Factory::without_network;

$u->prepare_test_from_file('t/data/rate-1-package');
$u->prepare_test_from_file('t/data/rate-1-package');
$u->prepare_test_from_file('t/data/rate-2-packages');
$u->prepare_test_from_file('t/data/shop-1-package');
$u->prepare_test_from_file('t/data/shop-2-packages');
$u->prepare_test_from_file('t/data/address');

Test::Net::UPS2::test_it($ups);

subtest 'HTTP failure' => sub {
    my $res;
    my $e = exception {
        $res = $ups->validate_address(
            Net::UPS2::Address->new({
                postal_code => '12345',
            }),
        );
    };

    ok(!defined $res && defined $e,'HTTP failure throws exception');
    cmp_deeply(
        $e,
        all(
            isa('Net::UPS2::Exception::HTTPError'),
            methods(
                response => methods(code=>500),
            ),
        ),
    );
    note "$e";
};

done_testing();
