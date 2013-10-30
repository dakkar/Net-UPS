package Test::Net::UPS::Factory;
use strict;
use warnings;
use File::Spec;
use Test::More;
use Net::UPS;
use Test::Net::UPS::NoNetwork;

sub from_config {
    my $upsrc = File::Spec->catfile($ENV{HOME}, '.upsrc');
    return (Net::UPS->new($upsrc) or do {
        plan(skip_all=>Net::UPS->errstr);
        exit(0);
    })
}

sub without_network {
    my ($args) = @_;
    return Test::Net::UPS::NoNetwork->new(
        'testid','testpass','testkey',$args
    );
}

1;
