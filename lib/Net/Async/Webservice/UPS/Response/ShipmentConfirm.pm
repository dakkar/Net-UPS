package Net::Async::Webservice::UPS::Response::ShipmentConfirm;
use Moo;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types qw(:types);
use namespace::autoclean;

extends 'Net::Async::Webservice::UPS::Response::ShipmentBase';

has shipment_digest => (
    is => 'ro',
    isa => Str,
    required => 1,
);

1;
