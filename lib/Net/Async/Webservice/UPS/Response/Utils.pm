package Net::Async::Webservice::UPS::Response::Utils;
use NAP::policy 'exporter';
use Sub::Exporter -setup => {
    exports => [qw(img_if pair_if base64_if
                   in_if out_if in_object_if in_datetime_if
                   set_implied_argument)],
};
use DateTime::Format::Strptime;
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

sub in_object_if {
    my ($attr,$key,$class) = @_;
    if ($implied_arg->{$key}) {
        return ($attr => $class->new($implied_arg->{$key}));
    }
    return;
}

sub in_datetime_if {
    my ($attr,$key) = @_;
    state $date_parser = DateTime::Format::Strptime->new(
        pattern => '%Y%m%d%H%M%S',
    );
    if ($implied_arg->{$key} && $implied_arg->{$key}{Date}) {
        return ( $attr => $date_parser->parse_datetime($implied_arg->{$key}{Date}.$implied_arg->{$key}{Time}) );
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
