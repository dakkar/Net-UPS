package Net::Async::Webservice::UPS::Response::ShipmentConfirm;
use Moo;
use Types::Standard qw(Str ArrayRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use namespace::autoclean;

extends 'Net::Async::Webservice::UPS::Response::ShipmentBase';

# ABSTRACT: UPS response to a ShipConfirm request

=head1 DESCRIPTION

This class is returned by
L<Net::Async::Webservice::UPS/ship_confirm>. It's a sub-class of
L<Net::Async::Webservice::UPS::Response::ShipmentBase>.

=attr C<shipment_digest>

A string with encoded information needed by UPS in the ShipAccept call.

=cut

has shipment_digest => (
    is => 'ro',
    isa => Str,
    required => 1,
);

=attr C<packages>

For internal use: the list of packages passed into the
L<Net::Async::Webservice::UPS/ship_confirm> call.

=cut

has packages => (
    is => 'ro',
    isa => ArrayRef[Package],
    required => 1,
);

1;
