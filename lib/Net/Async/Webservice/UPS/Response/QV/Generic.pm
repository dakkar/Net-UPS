package Net::Async::Webservice::UPS::Response::QV::Generic;
use Moo;
use 5.010;
use Types::Standard qw(Str ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils qw(:all);
use Types::DateTime DateTime => { -as => 'DateTimeT' };
use DateTime::Format::Strptime;
use List::AllUtils 'any';
use namespace::autoclean;

has activity_type => (
    is => 'ro',
    isa => Str,
);

has tracking_number => (
    is => 'ro',
    isa => Str,
);

has shipper_number => (
    is => 'ro',
    isa => Str,
);

has package_reference => (
    is => 'ro',
    isa => ArrayRef[QVReference],
);

has shipment_reference => (
    is => 'ro',
    isa => ArrayRef[QVReference],
);

has service => (
    is => 'ro',
    isa => HashRef,
);

has date_time => (
    is => 'ro',
    isa => DateTimeT,
);

has rescheduled_delivery_date => (
    is => 'ro',
    isa => DateTimeT,
);

has bill_to_account_number => (
    is => 'ro',
    isa => Str,
);
has bill_to_account_option => (
    is => 'ro',
    isa => Str,
);

has ship_to_location_id => (
    is => 'ro',
    isa => Str,
);
has ship_to_receiving_name => (
    is => 'ro',
    isa => Str,
);
has ship_to_bookmark => (
    is => 'ro',
    isa => Str,
);

has failure_email => (
    is => 'ro',
    isa => Str,
);
has failure_code => (
    is => 'ro',
    isa => Str,
);

sub BUILDARGS {
    my ($class,$hashref) = @_;
    if (@_>2) { shift; $hashref={@_} };

    if (any { /^[A-Z]/ } keys %$hashref) {
        state $date_parser = DateTime::Format::Strptime->new(
            pattern => '%Y%m%d',
        );

        set_implied_argument($hashref);
        return {
            in_if(activity_type=>'ActivityType'),
            in_if(tracking_number=>'TrackingNumber'),
            in_if(shipper_number=>'ShipperNumber'),
            in_object_array_if(shipment_reference => 'ShipmentReferenceNumber', 'Net::Async::Webservice::UPS::Response::QV::Reference'),
            in_object_array_if(package_reference => 'PackageReferenceNumber', 'Net::Async::Webservice::UPS::Response::QV::Reference'),
            in_if(service => 'Service'),
            in_datetime_if(date_time => 'Activity'),
            pair_if(bill_to_account_number => $hashref->{BillToAccount}{Number}),
            pair_if(bill_to_account_option => $hashref->{BillToAccount}{Option}),
            pair_if(ship_to_location_id => $hashref->{ShipTo}{LocationID}),
            pair_if(ship_to_receiving_name => $hashref->{ShipTo}{ReceivingAddressName}),
            pair_if(ship_to_bookmark => $hashref->{ShipTo}{Bookmark}),

            ( $hashref->{RescheduledDeliveryDate} ? ( rescheduled_delivery_date => $date_parser->parse_datetime($hashref->{RescheduledDeliveryDate}) ) : () ),

            pair_if(failure_email => $hashref->{FailureNotification}{FailedEmailAddress} ),
            pair_if(failure_code => $hashref->{FailureNotification}{FailureNotificationCode}{Code} ),
        }
    }
    return $hashref;
}

1;
