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

=attr C<warnings>

Hashref of warnings extracted from the UPS response.

=cut

has warnings => (
    is => 'ro',
    isa => HashRef,
    required => 0,
);

1;
