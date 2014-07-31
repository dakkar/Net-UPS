package Net::Async::Webservice::UPS::Response::ShipmentAccept;
use Moo;
use Types::Standard qw(Str ArrayRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use namespace::autoclean;

extends 'Net::Async::Webservice::UPS::Response::ShipmentBase';

has pickup_request_number => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has control_log => (
    is => 'ro',
    isa => Image,
    required => 0,
);

has package_results => (
    is => 'ro',
    isa => ArrayRef[PackageResult],
    required => 0,
);

1;
