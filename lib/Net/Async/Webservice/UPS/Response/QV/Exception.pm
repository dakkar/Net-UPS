package Net::Async::Webservice::UPS::Response::QV::Exception;
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

has updated_address => (
    is => 'ro',
    isa => Address,
);

has status_code => (
    is => 'ro',
    isa => Str,
);
has status_description => (
    is => 'ro',
    isa => Str,
);

has reason_code => (
    is => 'ro',
    isa => Str,
);
has reason_description => (
    is => 'ro',
    isa => Str,
);

has resolution_code => (
    is => 'ro',
    isa => Str,
);
has resolution_description => (
    is => 'ro',
    isa => Str,
);

has rescheduled_delivery_date => (
    is => 'ro',
    isa => DateTimeT,
);

has activity_location => (
    is => 'ro',
    isa => Address,
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
            in_object_if(updated_address => 'UpdatedAddress', 'Net::Async::Webservice::UPS::Address'),
            pair_if(bill_to_account_number => $hashref->{BillToAccount}{Number}),
            pair_if(bill_to_account_option => $hashref->{BillToAccount}{Option}),
            in_if(status_code => 'StatusCode'),
            ( $hashref->{RescheduledDeliveryDate} ? ( rescheduled_delivery_date => $date_parser->parse_datetime($hashref->{RescheduledDeliveryDate}.$hashref->{RescheduledDeliveryTime}) ) : () ),
            in_if(status_code => 'StatusCode'),
            in_if(status_description => 'StatusDescription'),
            in_if(reason_code => 'ReasonCode'),
            in_if(reason_description => 'ReasonDescription'),
            pair_if(resolution_code => $hashref->{Resolution}{Code}),
            pair_if(resolution_description => $hashref->{Resolution}{Description}),
            in_object_if(activity_location => 'ActivityLocation', 'Net::Async::Webservice::UPS::Address'),
            in_if(access_point_location_id => 'AccessPointLocationID'),
        };
    }
    return $hashref;
}


1;
