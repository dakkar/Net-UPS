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
    my $ups = try {
        Net::UPS2->new({
            config_file => $upsrc,
            user_agent => Test::Net::UPS::Tracing->new(),
        })
      } catch {
          plan(skip_all=>"$_");
          exit(0);
      };
    return $ups;
}

sub without_network {
    my ($args) = @_;
    my $ret = Net::UPS2->new({
        user_id => 'testid',
        password => 'testpass',
        access_key => 'testkey',
        user_agent => Test::Net::UPS::NoNetwork->new(),
        %{$args//{}},
    });
    return $ret;
}

1;
