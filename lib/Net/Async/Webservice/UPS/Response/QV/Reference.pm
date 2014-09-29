package Net::Async::Webservice::UPS::Response::QV::Reference;
use Moo;
use Types::Standard qw(Str ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils qw(:all);
use namespace::autoclean;

has number => (
    is => 'ro',
    isa => Str,
);

has code => (
    is => 'ro',
    isa => Str,
);

has value => (
    is => 'ro',
    isa => Str,
);

sub BUILDARGS {
    my ($class,$hashref) = @_;
    if (@_>2) { shift; $hashref={@_} };

    if ($hashref->{Number}) {
        set_implied_argument($hashref);
        return {
            in_if(number=>'Number'),
            in_if(code=>'Code'),
            in_if(value=>'Value'),
        };
    }
    return $hashref;
}

1;
