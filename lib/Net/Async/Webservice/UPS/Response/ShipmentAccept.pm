package Net::Async::Webservice::UPS::Response::ShipmentAccept;
use Moo;
use Types::Standard qw(Str ArrayRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use namespace::autoclean;

extends 'Net::Async::Webservice::UPS::Response::ShipmentBase';

# ABSTRACT: UPS response to a ShipAccept request

=head1 DESCRIPTION

This class is returned by
L<Net::Async::Webservice::UPS/ship_accept>. It's a sub-class of
L<Net::Async::Webservice::UPS::Response::ShipmentBase>.

=attr C<pickup_request_number>

Not sure what this means.

=cut

has pickup_request_number => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<control_log>

An instance of L<Net::Async::Webservice::UPS::Response::Image>, not
sure what this means.

=cut

has control_log => (
    is => 'ro',
    isa => Image,
    required => 0,
);

=attr C<package_results>

Array ref of L<Net::Async::Webservice::UPS::Response::PackageResult>.

=cut

has package_results => (
    is => 'ro',
    isa => ArrayRef[PackageResult],
    required => 0,
);

1;