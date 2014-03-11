package Test::Net::Async::UPS::Factory;
use strict;
use warnings;
use File::Spec;
use Test::More;
use Try::Tiny;
use Net::Async::UPS;
use IO::Async::Loop;
use Test::Net::Async::UPS::NoNetwork;
use Test::Net::Async::UPS::Tracing;

sub from_config {
    my $loop = IO::Async::Loop->new;
    my $upsrc = File::Spec->catfile($ENV{HOME}, '.upsrc.conf');
    my $ups = try {
        Net::Async::UPS->new({
            config_file => $upsrc,
            loop => $loop,
        })
      } catch {
          plan(skip_all=>"$_");
          exit(0);
      };
    return ($ups,$loop);
}

sub from_config_tracing {
    my $upsrc = File::Spec->catfile($ENV{HOME}, '.upsrc.conf');
    my $loop = IO::Async::Loop->new;
    my $ua = Test::Net::Async::UPS::Tracing->new({loop=>$loop});
    my $ups = try {
        Net::Async::UPS->new({
            config_file => $upsrc,
            user_agent => $ua,
        })
      } catch {
          plan(skip_all=>"$_");
          exit(0);
      };
    return ($ups,$ua);
}

sub without_network {
    my ($args) = @_;
    my $ua = Test::Net::Async::UPS::NoNetwork->new();
    my $ret = Net::Async::UPS->new({
        user_id => 'testid',
        password => 'testpass',
        access_key => 'testkey',
        user_agent => $ua,
        %{$args//{}},
    });
    return ($ret,$ua);
}

1;
