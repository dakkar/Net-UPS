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
    required => 1,
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

# Manifests are not yet supported

my %typemap = (
    Origin => 'Net::Async::Webservice::UPS::Response::QV::Origin',
    Generic => 'Net::Async::Webservice::UPS::Response::QV::Generic',
    Delivery => 'Net::Async::Webservice::UPS::Response::QV::Delivery',
    #Manifest => 'Net::Async::Webservice::UPS::Response::QV::Manifest',
    Exception => 'Net::Async::Webservice::UPS::Response::QV::Exception',
);
my %slotmap = (
    Origin => 'origins',
    Generic => 'generics',
    Delivery => 'deliveries',
    #Manifest => 'manifests',
    Exception => 'exceptions',
);

sub BUILDARGS {
    my ($class,$hashref) = @_;
    if (@_>2) { shift; $hashref={@_} };

    if ($hashref->{FileName}) {
        set_implied_argument($hashref);

        my $ret = {
            in_if(filename => 'FileName'),
            in_if(status => 'StatusType'),
        };
        for my $k (sort keys %typemap) {
            my $slot = $slotmap{$k};
            my $class = $typemap{$k};

            if ($hashref->{$k}) {
                my $array = $hashref->{$k};
                if (ref($array) ne 'ARRAY') {
                    $array = [ $array ];
                }

                $ret->{$slot} = [ map {
                    $class->new($_)
                } @{$array} ];
            }
        }
    }
    return $hashref;
}

1;
