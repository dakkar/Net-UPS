package Net::Async::Webservice::UPS::Shipper;
use Moo;
use 5.010;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types ':types';
extends 'Net::Async::Webservice::UPS::Contact';

has account_number => (
    is => 'ro',
    isa => Str,
);

sub as_hash {
    my ($self) = @_;

    my $ret = $self->next::method;
    if ($self->account_number) {
        $ret->{ShipperNumber} = $self->account_number;
    }
    return $ret;
}

1;
