#!perl
use strict;
use warnings;
use Test::Most;
use Test::Fatal;
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

subtest 'HTTP failure' => sub {
    my $res;
    my $e = exception {
        $res = $ups->validate_address(
            Net::UPS2::Address->new({
                postal_code => '12345',
            }),
        );
    };

    ok(!defined $res && !defined $e,'HTTP failure does not throw exception');
    like(
        $ups->errstr,
        qr{\AError POSTing https://wwwcie.ups.com/ups.app/xml/AV: 500\b},
        'HTTP exception stringified and set',
    );
};

subtest 'UPS failure' => sub {
    $u->prepare_test_from_file('t/data/address-fail');

    my $res;
    my $e = exception {
        $res = $ups->validate_address(
            Net::UPS2::Address->new({
                postal_code => '12345',
            }),
        );
    };

    ok(!defined $res && !defined $e,'UPS failure does not throw exception');

    like(
        $ups->errstr,
        qr{\Amanual failure for testing\z},
        'UPS exception stringified and set',
    );
};

done_testing();
