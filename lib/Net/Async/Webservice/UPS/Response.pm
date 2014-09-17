package Net::Async::Webservice::UPS::Response;
use Moo;
use Types::Standard qw(Str);
use namespace::autoclean;

# ABSTRACT: base class with fields common to all UPS responses

=attr C<customer_context>

A string, usually whatever was passed to the request as C<customer_context>.

=cut

has customer_context => (
    is => 'ro',
    isa => Str,
);

1;
