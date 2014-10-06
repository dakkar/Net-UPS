package Net::Async::Webservice::UPS::Response::QV::Delivery;
use Moo;
use 5.010;
use Types::Standard qw(Str ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils qw(:all);
use Types::DateTime DateTime => { -as => 'DateTimeT' };
use DateTime::Format::Strptime;
use List::AllUtils 'any';
use namespace::autoclean;

# ABSTRACT: a Quantum View "delivery" event

=for Pod::Coverage BUILDARGS

=head1 DESCRIPTION

Object representing the
C<QuantumViewEvents/SubscriptionEvents/SubscriptionFile/Delivery>
elements in the Quantum View response. Attribute descriptions come
from the official UPS documentation.

=attr C<package_reference>

Optional array of
L<Net::Async::Webservice::UPS::Response::QV::Reference>, package-level
reference numbers.

=cut

has package_reference => (
    is => 'ro',
    isa => ArrayRef[QVReference],
);

=attr C<shipment_reference>

Optional array of
L<Net::Async::Webservice::UPS::Response::QV::Reference>, shipment-level
reference numbers.

=cut

has shipment_reference => (
    is => 'ro',
    isa => ArrayRef[QVReference],
);

=attr C<shipper_number>

Optional string, shipper's six digit alphanumeric account number.

=cut

has shipper_number => (
    is => 'ro',
    isa => Str,
);

=attr C<tracking_number>

Optional string, package's 1Z tracking number.

=cut

has tracking_number => (
    is => 'ro',
    isa => Str,
);

=attr C<date_time>

Optional L<DateTime>, date and time that the package is delivered,
most probably with a floating timezone.

=cut

has date_time => (
    is => 'ro',
    isa => DateTimeT,
);

=attr C<activity_location>

Optional L<Net::Async::Webservice::UPS::Address>, geographic location
where an activity occurred during a movement of a package or shipment.

=cut

has activity_location => (
    is => 'ro',
    isa => Address,
);

=attr C<delivery_location>

Optional L<Net::Async::Webservice::UPS::Address>, location where
package is delivered.

=cut

has delivery_location => (
    is => 'ro',
    isa => Address,
);

=attr C<delivery_location_code>

Optional string, Location Code for delivered package.

=cut

has delivery_location_code => (
    is => 'ro',
    isa => Str,
);

=attr C<delivery_location_descripton>

Optional string, description of the location where package is delivered.

=cut

has delivery_location_descripton => (
    is => 'ro',
    isa => Str,
);

=attr C<signed_for_by>

Optional string, the person who signed for the package.

=cut

has signed_for_by => (
    is => 'ro',
    isa => Str,
);

=attr C<driver_release>

Optional string, information about driver release note / signature.

=cut

has driver_release => (
    is => 'ro',
    isa => Str,
);

=attr C<cod_currency>

Optional string, the IATA currency code associated with the COD amount
for the package.

=cut

has cod_currency => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<cod_value>

Optional string, the monetary amount of the COD.

=cut

has cod_value => (
    is => 'ro',
    isa => Measure,
    required => 0,
);

=attr C<bill_to_account_number>

Optional string, the UPS Account number to which the shipping charges
were billed.

=cut

has bill_to_account_number => (
    is => 'ro',
    isa => Str,
);

=attr C<bill_to_account_option>

Optional string, indicates how shipping charges for the package were
billed. Valid Values: 01 Shipper, 02 Consignee Billing , 03 Third
Party, 04 Freight Collect.

=cut

has bill_to_account_option => (
    is => 'ro',
    isa => Str,
);

=attr C<access_point_location_id>

Optional string, the UPS Access Point Location ID.

=cut

has access_point_location_id => (
    is => 'ro',
    isa => Str,
);

=attr C<last_pickup>

Optional string, last pickup by Date from the UPS Access Point
Location (yes, a string, the format does not seem to be specified)

=cut

has last_pickup => (
    is => 'ro',
    isa => Str,
);

sub BUILDARGS {
    my ($class,$hashref) = @_;
    if (@_>2) { shift; $hashref={@_} };

    if (any { /^[A-Z]/ } keys %$hashref) {
        state $date_parser = DateTime::Format::Strptime->new(
            pattern => '%Y%m%d%H%M%S',
        );
        set_implied_argument($hashref);

        return {
            in_if(tracking_number=>'TrackingNumber'),
            in_if(shipper_number=>'ShipperNumber'),
            in_object_array_if(shipment_reference => 'ShipmentReferenceNumber', 'Net::Async::Webservice::UPS::Response::QV::Reference'),
            in_object_array_if(package_reference => 'PackageReferenceNumber', 'Net::Async::Webservice::UPS::Response::QV::Reference'),
            ( $hashref->{Date} ? ( date_time => $date_parser->parse_datetime($hashref->{Date}.$hashref->{Time}) ) : () ),
            in_object_if(activity_location => 'ActivityLocation', 'Net::Async::Webservice::UPS::Address'),
            in_object_if(delivery_location => 'DeliveryLocation', 'Net::Async::Webservice::UPS::Address'),
            pair_if(delivery_location_code => $hashref->{DeliveryLocation}{Code}),
            pair_if(delivery_location_descripton => $hashref->{DeliveryLocation}{Description}),
            pair_if(signed_for_by => $hashref->{DeliveryLocation}{SignedForByName}),
            in_if(driver_release => 'DriverRelease'),
            pair_if(cod_currency => $hashref->{COD}{CODAmount}{CurrencyCode}),
            pair_if(cod_value => $hashref->{COD}{CODAmount}{MonetaryValue}),
            pair_if(bill_to_account_number => $hashref->{BillToAccount}{Number}),
            pair_if(bill_to_account_option => $hashref->{BillToAccount}{Option}),
            in_if(access_point_location_id => 'AccessPointLocationID'),
            in_if(last_pickup => 'LastPickupDate'),
        };
    }
    return $hashref;
}

1;
