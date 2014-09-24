package Net::Async::Webservice::UPS::Response::Rate;
use Moo;
use Types::Standard qw(ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use namespace::autoclean;

extends 'Net::Async::Webservice::UPS::Response';

# ABSTRACT: response for request_rate

=head1 DESCRIPTION

Instances of this class are returned (in the Future) by calls to
L<Net::Async::Webservice::UPS/request_rate>.

=attr C<services>

Array ref of services that you can use to ship the packages passed in
to C<request_rate>. Each one will have a set of rates, one per
package.

=cut

has services => (
    is => 'ro',
    isa => ArrayRef[Service],
    required => 1,
);

1;
