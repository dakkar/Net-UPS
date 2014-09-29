package Net::Async::Webservice::UPS::Response::Address;
use Moo;
use Types::Standard qw(ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use namespace::autoclean;

extends 'Net::Async::Webservice::UPS::Response';

# ABSTRACT: response for validate_address

=head1 DESCRIPTION

Instances of this class are returned (in the Future) by calls to
L<Net::Async::Webservice::UPS/validate_address>.

=attr C<addresses>

Array ref of addresses that correspond to the one passed in to
C<validate_address>. Each one will have its own C<quality> rating.

=cut

has addresses => (
    is => 'ro',
    isa => ArrayRef[Address],
    required => 1,
);

sub BUILDARGS {
    my ($class,$hashref) = @_;
    if (@_>2) { shift; $hashref={@_} };

    my $ret = $class->next::method($hashref);

    if ($hashref->{addresses} and not $ret->{addresses}) {
        $ret->{addresses} = $hashref->{addresses};
    }

    return $ret;
}

1;
