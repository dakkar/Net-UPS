package Net::Async::Webservice::UPS::Response::ShipmentBase;
use Moo;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types qw(:types);
use namespace::autoclean;

=attr C<measurement_system>

Either C<metric> (centimeters and kilograms) or C<english> (inches and
pounds), required.

=cut

has unit => (
    is => 'ro',
    isa => MeasurementUnit,
    required => 1,
);

has billing_weight => (
    is => 'ro',
    isa => Measure,
    required => 1,
);

has currency => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has service_option_charges => (
    is => 'ro',
    isa => Measure,
    required => 1,
);

has total_charges => (
    is => 'ro',
    isa => Measure,
    required => 1,
);

has transportation_charges => (
    is => 'ro',
    isa => Measure,
    required => 1,
);

has shipment_identification_number => (
    is => 'ro',
    isa => Str,
    required => 1,
);

1;
