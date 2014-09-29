package Net::Async::Webservice::UPS::Response::Utils;
use NAP::policy 'exporter';
use Sub::Exporter -setup => {
    exports => [qw(img_if pair_if base64_if in_if out_if set_implied_argument)],
};
use Scope::Upper qw(reap :words);

my $implied_arg;

sub set_implied_argument {
    my ($value) = @_;

    $implied_arg = $value;
    reap { undef $implied_arg } UP;
}

sub out_if {
    my ($key,$attr) = @_;
    if ($implied_arg->$attr) {
        return ($key => $implied_arg->$attr);
    }
    return;
}
sub in_if {
    my ($attr,$key) = @_;
    if ($implied_arg->{$key}) {
        return ($attr => $implied_arg->{$key});
    }
    return;
}

sub pair_if {
    return @_ if $_[1];
    return;
}

sub img_if {
    return ( $_[0] => Net::Async::Webservice::UPS::Response::Image->new($_[1]) ) if $_[1] && %{$_[1]};
    return;
}

sub base64_if {
    return ($_[0],decode_base64($_[1])) if $_[1];
    return;
}
