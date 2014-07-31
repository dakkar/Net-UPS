package Net::Async::Webservice::UPS::Response::PackageResult;
use Moo;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types qw(:types);
use namespace::autoclean;

has tracking_number => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has currency => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has service_option_charges => (
    is => 'ro',
    isa => Measure,
    required => 0,
);

has label => (
    is => 'ro',
    isa => Image,
    required => 0,
);

has signature => (
    is => 'ro',
    isa => Image,
    required => 0,
);

has html => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has pdf417 => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has receipt => (
    is => 'ro',
    isa => Image,
    required => 0,
);

has form_code => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has form_image => (
    is => 'ro',
    isa => Image,
    required => 0,
);

has form_group_id => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has cod_turn_in => (
    is => 'ro',
    isa => Image,
    required => 0,
);

1;
