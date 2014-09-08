package Net::Async::Webservice::UPS::Response::ShipmentBase;
use Moo;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types qw(:types);
use namespace::autoclean;

# ABSTRACT: base class for UPS shipment responses

=attr C<unit>

Either C<KGS> or C<LBS>, unit of measurement for the
L</billing_weight>. Required.

=cut

has unit => (
    is => 'ro',
    isa => WeightMeasurementUnit,
    required => 1,
);

=attr C<billing_weight>

Number, the shipment weight you're being billed for, measured in
kilograms or pounds accourding to L</unit>.

=cut

has billing_weight => (
    is => 'ro',
    isa => Measure,
    required => 1,
);

=attr C<currency>

String, the currency code for all the charges.

=cut

has currency => (
    is => 'ro',
    isa => Str,
    required => 1,
);

=attr C<service_option_charges>

Number, how much the service option costs (in L</currency>).

=cut

has service_option_charges => (
    is => 'ro',
    isa => Measure,
    required => 1,
);

=attr C<transportation_charges>

Number, how much the transport costs (in L</currency>).

=cut

has transportation_charges => (
    is => 'ro',
    isa => Measure,
    required => 1,
);

=attr C<total_charges>

Number, how much you're being billed for (in L</currency>).

=cut

has total_charges => (
    is => 'ro',
    isa => Measure,
    required => 1,
);

=attr C<shipment_identification_number>

Unique string that UPS will use to identify this shipment.

=cut

has shipment_identification_number => (
    is => 'ro',
    isa => Str,
    required => 1,
);

1;
