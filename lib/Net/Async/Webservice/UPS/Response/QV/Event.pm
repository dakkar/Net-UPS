package Net::Async::Webservice::UPS::Response::QV::Event;
use Moo;
use 5.010;
use Types::Standard qw(Str ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils ':all';
use Types::DateTime DateTime => { -as => 'DateTimeT' };
use DateTime::Format::Strptime;
use namespace::autoclean;

# ABSTRACT: a Quantum View "event"

=for Pod::Coverage BUILDARGS

=head1 DESCRIPTION

Object representing the C<QuantumViewEvents/SubscriptionEvents>
elements in the Quantum View response. Attribute descriptions come
from the official UPS documentation.

=attr C<name>

String, a name uniquely defined associated to the Subscription ID, for
each subscription.

=cut

has name => (
    is => 'ro',
    isa => Str,
    required => 1,
);

=attr C<number>

String, a number uniquely defined associated to the Subscriber ID, for
each subscription.

=cut

has number => (
    is => 'ro',
    isa => Str,
    required => 1,
);

=attr C<status>

Hashref, with keys:

=for :list
= C<Code>
required, status types of subscription; valid values are: C<UN> – Unknown, C<AT> – Activate, C<P> – Pending, C<A> –Active, C<I> – Inactive, C<S> - Suspended
= C<Description>
optional, description of the status

=cut

has status => (
    is => 'ro',
    isa => HashRef,
    required => 1,
);

=attr C<files>

Array ref of L<Net::Async::Webservice::UPS::Response::QV::File>

=cut

has files => (
    is => 'ro',
    isa => ArrayRef[QVFile],
    required => 1,
);

=attr C<begin_date>

Optional, beginning date-time of subscription requested by user. It's
a L<DateTime> object, most probably with a floating timezone.

=cut

has begin_date => (
    is => 'ro',
    isa => DateTimeT,
    required => 0,
);

=attr C<end_date>

Optional, ending date-time of subscription requested by user. It's a
L<DateTime> object, most probably with a floating timezone.

=cut

has end_date => (
    is => 'ro',
    isa => DateTimeT,
    required => 0,
);

sub BUILDARGS {
    my ($class,$hashref) = @_;
    if (@_>2) { shift; $hashref={@_} };

    if ($hashref->{Name}) {
        state $date_parser = DateTime::Format::Strptime->new(
            pattern => '%Y%m%d%H%M%S',
        );
        set_implied_argument($hashref);

        return {
            in_if(name=>'Name'),
            in_if(number=>'Number'),
            in_if(status=>'SubscriptionStatus'),
            ( $hashref->{DateRange}{BeginDate} ? ( begin_date => $date_parser->parse_datetime($hashref->{DateRange}{BeginDate}) ) : () ),
            ( $hashref->{DateRange}{EndDate} ? ( end_date => $date_parser->parse_datetime($hashref->{DateRange}{EndDate}) ) : () ),
            in_object_array_if(files=>'SubscriptionFile','Net::Async::Webservice::UPS::Response::QV::File'),
        };
    }
    return $hashref;
}

1;
