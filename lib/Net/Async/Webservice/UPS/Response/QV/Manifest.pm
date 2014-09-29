package Net::Async::Webservice::UPS::Response::QV::Manifest;
use Moo;
use Types::Standard qw(Str Bool ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Types::DateTime DateTime => { -as => 'DateTimeT' };
use namespace::autoclean;

# INCOMPLETE and UNUSED!

has pickup_date => (
    is => 'ro',
    isa => DateTimeT,
    required => 0,
);

has sheduled_delivery_date => (
    is => 'ro',
    isa => DateTimeT,
    required => 0,
);

has service => (
    is => 'ro',
    isa => Service,
    required => 0,
);

has shipper => (
    is => 'ro',
    isa => Shipper,
    required => 0,
);

has from => (
    is => 'ro',
    isa => Address,
    required => 0,
);

has to => (
    is => 'ro',
    isa => Contact,
    required => 0,
);

has reference_number => (
    is => 'ro',
    isa => HashRef,
    required => 0,
);

has document_only => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has packages => (
    is => 'ro',
    isa => ArrayRef[QVPackage],
    required => 0,
);

has saturday_delivery => (
    is => 'ro',
    isa => Bool,
    required => 0,
);

has saturday_pickup => (
    is => 'ro',
    isa => Bool,
    required => 0,
);

has call_tag => (
    is => 'ro',
    isa => HashRef,
    required => 0,
);

# TODO continue from page 60

1;
