package Net::Async::Webservice::UPS::Response;
use Moo;
use Types::Standard qw(Str HashRef);
use namespace::autoclean;

# ABSTRACT: base class with fields common to all UPS responses

=attr C<customer_context>

A string, usually whatever was passed to the request as C<customer_context>.

=cut

has customer_context => (
    is => 'ro',
    isa => Str,
);

=attr C<warnings>

Hashref of warnings extracted from the UPS response.

=cut

has warnings => (
    is => 'ro',
    isa => HashRef,
    required => 0,
);

sub BUILDARGS {
    my ($class,@etc) = @_;

    my $hashref = $class->next::method(@etc);
    if ($hashref->{Response}) {
        return {
            customer_context => $hashref->{Response}{TransactionReference}{CustomerContext},
            ( $hashref->{Response}{Error} ? (warnings => $hashref->{Response}{Error}) : () ),
        }
    }
    else {
        return $hashref;
    }
}

1;
