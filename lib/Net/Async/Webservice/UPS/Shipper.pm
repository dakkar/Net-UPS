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

sub cache_id {
    my ($self) = @_;

    return join ':',
        $self->account_number,
        $self->address->cache_id;
}

1;
