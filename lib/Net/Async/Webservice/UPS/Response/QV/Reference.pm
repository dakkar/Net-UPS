package Net::Async::Webservice::UPS::Response::QV::Reference;
use Moo;
use Types::Standard qw(Str ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils qw(:all);
use namespace::autoclean;

# ABSTRACT: a Quantum View package or shipment reference

=for Pod::Coverage BUILDARGS

=head1 DESCRIPTION

Object representing the C<PackageReferenceNumber> or
C<ShipmentReferenceNumber> elements in the Quantum View
response. Attribute descriptions come from the official UPS
documentation.

=attr C<number>

Optional string, number tag.

=cut

has number => (
    is => 'ro',
    isa => Str,
);

=attr C<code>

Optional string, reflects what will go on the label as the name of the
reference.

=cut

has code => (
    is => 'ro',
    isa => Str,
);

=attr C<value>

Optional string, customer supplied reference number. Reference numbers
are defined by the shipper and can contain any character string.

=cut

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
