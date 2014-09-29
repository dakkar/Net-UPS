package Net::Async::Webservice::UPS::Response::QV::File;
use Moo;
use Types::Standard qw(Str ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils ':all';
use namespace::autoclean;

has filename => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has status => (
    is => 'ro',
    isa => HashRef,
    required => 0,
);

has origins => (
    is => 'ro',
    isa => ArrayRef[QVOrigin],
    required => 0,
);

has generics => (
    is => 'ro',
    isa => ArrayRef[QVGeneric],
    required => 0,
);

has manifests => (
    is => 'ro',
    isa => ArrayRef[QVManifest],
    required => 0,
);

has deliveries => (
    is => 'ro',
    isa => ArrayRef[QVDelivery],
    required => 0,
);

has exceptions => (
    is => 'ro',
    isa => ArrayRef[QVException],
    required => 0,
);

sub BUILDARGS {
    my ($class,$hashref) = @_;
    if (@_>2) { shift; $hashref={@_} };

    if ($hashref->{FileName}) {
        set_implied_argument($hashref);

        return {
            in_if(filename => 'FileName'),
            in_if(status => 'StatusType'),
            in_object_array_if(origins=>'Origin','Net::Async::Webservice::UPS::Response::QV::Origin'),
            in_object_array_if(generics=>'Generic','Net::Async::Webservice::UPS::Response::QV::Generic'),
            in_object_array_if(deliveries=>'Delivery','Net::Async::Webservice::UPS::Response::QV::Delivery'),
            # Manifests are not yet supported
            #in_object_array_if(manifests=>'Manifest','Net::Async::Webservice::UPS::Response::QV::Manifest'),
            in_object_array_if(exceptions=>'Exception','Net::Async::Webservice::UPS::Response::QV::Exception'),
        };
    }
    return $hashref;
}

1;
