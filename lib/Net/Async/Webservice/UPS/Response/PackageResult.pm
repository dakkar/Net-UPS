package Net::Async::Webservice::UPS::Response::PackageResult;
use Moo;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types qw(:types);
use namespace::autoclean;

# ABSTRACT: information about a package in a booked shipment

=head1 DESCRIPTION

Instances of this class are returned as part of
L<Net::Async::Webservice::UPS::Response::ShipmentAccept> by
L<Net::Async::Webservice::UPS/ship_accept>.

=attr C<tracking_number>

String, tracking code for this package.

=cut

has tracking_number => (
    is => 'ro',
    isa => Str,
    required => 1,
);

=attr C<currency>

String, the currency code for all the charges.

=cut

has currency => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<service_option_charges>

Number, how much the service option costs (in L</currency>) for this package.

=cut

has service_option_charges => (
    is => 'ro',
    isa => Measure,
    required => 0,
);

=attr L<label>

An instance of L<Net::Async::Webservice::UPS::Response::Image>, label
to print for this package.

=cut

has label => (
    is => 'ro',
    isa => Image,
    required => 0,
);

=attr L<signature>

An instance of L<Net::Async::Webservice::UPS::Response::Image>, not
sure what this is for.

=cut

has signature => (
    is => 'ro',
    isa => Image,
    required => 0,
);

=attr L<html>

HTML string, not sure what this is for.

=cut

has html => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr L<pdf417>

String of bytes containing a PDF417 barcode, not sure what this is for.

=cut

has pdf417 => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr L<receipt>

An instance of L<Net::Async::Webservice::UPS::Response::Image>, not
sure what this is for.

=cut

has receipt => (
    is => 'ro',
    isa => Image,
    required => 0,
);

=attr C<form_code>

String, not sure what this is for.

=cut

has form_code => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr L<form_image>

An instance of L<Net::Async::Webservice::UPS::Response::Image>, not
sure what this is for.

=cut

has form_image => (
    is => 'ro',
    isa => Image,
    required => 0,
);

=attr C<form_group_id>

String, not sure what this is for.

=cut

has form_group_id => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<cod_turn_in>

An instance of L<Net::Async::Webservice::UPS::Response::Image>, not
sure what this is for.

=cut

has cod_turn_in => (
    is => 'ro',
    isa => Image,
    required => 0,
);

1;
