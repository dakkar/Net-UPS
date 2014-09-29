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

has package_reference => (
    is => 'ro',
    isa => ArrayRef[QVReference],
);

has shipment_reference => (
    is => 'ro',
    isa => ArrayRef[QVReference],
);

has shipper_number => (
    is => 'ro',
    isa => Str,
);

has tracking_number => (
    is => 'ro',
    isa => Str,
);

has date_time => (
    is => 'ro',
    isa => DateTimeT,
);

has activity_location => (
    is => 'ro',
    isa => Address,
);

has delivery_location => (
    is => 'ro',
    isa => Address,
);

has delivery_location_code => (
    is => 'ro',
    isa => Str,
);
has delivery_location_descripton => (
    is => 'ro',
    isa => Str,
);
has signed_for_by => (
    is => 'ro',
    isa => Str,
);

has driver_release => (
    is => 'ro',
    isa => Str,
);

has cod_currency => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has cod_value => (
    is => 'ro',
    isa => Measure,
    required => 0,
);

has bill_to_account_number => (
    is => 'ro',
    isa => Str,
);
has bill_to_account_option => (
    is => 'ro',
    isa => Str,
);

has access_point_location_id => (
    is => 'ro',
    isa => Str,
);

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
