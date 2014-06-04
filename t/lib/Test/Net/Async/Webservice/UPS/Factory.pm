package Test::Net::Async::Webservice::UPS::Factory;
use strict;
use warnings;
use File::Spec;
use Test::More;
use Net::Async::Webservice::UPS;
use IO::Async::Loop;
use Test::Net::Async::Webservice::UPS::NoNetwork;
use Test::Net::Async::Webservice::UPS::Tracing;
use Test::Net::Async::Webservice::UPS;
use LWP::UserAgent;

sub from_config {
    my $loop = IO::Async::Loop->new;

    my $ups = Net::Async::Webservice::UPS->new({
        config_file => Test::Net::Async::Webservice::UPS->conf_file,
        loop => $loop,
    });
    return ($ups,$loop);
}

sub from_config_sync {
    my $ua = LWP::UserAgent->new;

    my $ups = Net::Async::Webservice::UPS->new({
        config_file => Test::Net::Async::Webservice::UPS->conf_file,
        user_agent => $ua,
    });
    return ($ups,$ua);
}

sub from_config_tracing {
    my $loop = IO::Async::Loop->new;
    my $ua = Test::Net::Async::Webservice::UPS::Tracing->new({loop=>$loop});
    my $ups = Net::Async::Webservice::UPS->new({
        config_file => Test::Net::Async::Webservice::UPS->conf_file,
        user_agent => $ua,
    });
    return ($ups,$ua);
}

sub without_network {
    my ($args) = @_;
    my $ua = Test::Net::Async::Webservice::UPS::NoNetwork->new();
    my $ret = Net::Async::Webservice::UPS->new({
        user_id => 'testid',
        password => 'testpass',
        access_key => 'testkey',
        user_agent => $ua,
        %{$args//{}},
    });
    return ($ret,$ua);
}

1;
