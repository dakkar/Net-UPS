package Test::Net::UPS::Factory;
use strict;
use warnings;
use File::Spec;
use Test::More;
use Net::UPS;
use Test::Net::UPS::NoNetwork;
use Test::Net::UPS::Tracing;

sub from_config {
    my $upsrc = File::Spec->catfile($ENV{HOME}, '.upsrc');
    return (Net::UPS->new($upsrc) or do {
        plan(skip_all=>Net::UPS->errstr);
        exit(0);
    })
}

sub from_config_tracing {
    my $upsrc = File::Spec->catfile($ENV{HOME}, '.upsrc');
    my $ret = Net::UPS->new($upsrc) or do {
        plan(skip_all=>Net::UPS->errstr);
        exit(0);
    };
    $ret->{delegate}{user_agent} = Test::Net::UPS::Tracing->new();
    return $ret;
}

sub without_network {
    my ($args) = @_;
    my $ret = Net::UPS->new(
        'testid','testpass','testkey',$args
    );
    $ret->{delegate}{user_agent} = Test::Net::UPS::NoNetwork->new();
    return $ret;
}

1;
