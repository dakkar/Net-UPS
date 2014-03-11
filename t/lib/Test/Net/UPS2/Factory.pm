package Test::Net::UPS2::Factory;
use strict;
use warnings;
use File::Spec;
use Test::More;
use Try::Tiny;
use Net::UPS2;
use Test::Net::UPS::NoNetwork;
use Test::Net::UPS::Tracing;

sub from_config {
    my $upsrc = File::Spec->catfile($ENV{HOME}, '.upsrc.conf');
    my $ups = try {
        Net::UPS2->new($upsrc)
      } catch {
          plan(skip_all=>"$_");
          exit(0);
      };
    return $ups;
}

sub from_config_tracing {
    my $upsrc = File::Spec->catfile($ENV{HOME}, '.upsrc.conf');
    my $ua = Test::Net::UPS::Tracing->new();
    my $ups = try {
        Net::UPS2->new({
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
    my $ua = Test::Net::UPS::NoNetwork->new();
    my $ret = Net::UPS2->new({
        user_id => 'testid',
        password => 'testpass',
        access_key => 'testkey',
        user_agent => $ua,
        %{$args//{}},
    });
    return ($ret,$ua);
}

1;