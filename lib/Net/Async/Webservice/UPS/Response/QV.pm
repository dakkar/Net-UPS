package Net::Async::Webservice::UPS::Response::QV;
use Moo;
use Types::Standard qw(Str ArrayRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils ':all';
use namespace::autoclean;
extends 'Net::Async::Webservice::UPS::Response';

# ABSTRACT: response for qv_events

=for Pod::Coverage BUILDARGS

=head1 DESCRIPTION

Instances of this class are returned (in the Future) by calls to
L<Net::Async::Webservice::UPS/qv_events>.

=attr C<subscriber_id>

The UPS Quantum View subscriber id. It's the same as the UPS user id.

=cut

has subscriber_id => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<events>

Array ref of L<Net::Async::Webservice::UPS::Response::QV::Event>

=cut

has events => (
    is => 'ro',
    isa => ArrayRef[QVEvent],
    required => 0,
);

=attr C<bookmark>

String used to paginate long results. Use it like this:

  use feature 'current_sub';

  $ups->qv_events($args)->then(sub {
   my ($response) = @_;
   do_something_with($response);
   if ($response->bookmark) {
     $args->{bookmark} = $response->bookmark;
     return $ups->qv_events($args)->then(__SUB__);
   }
   else {
    return Future->done()
   }
  });

So:

=for :list
* a response without a bookmark is the last one
* if there is a bookmark, a new request must be performed with the same subscriptions, plus the bookmark

(yes, the example requires Perl 5.16, but that's just to make it
compact)

=cut

has bookmark => (
    is => 'ro',
    isa => Str,
    required => 0,
);

sub BUILDARGS {
    my ($class,$hashref) = @_;
    if (@_>2) { shift; $hashref={@_} };

    my $ret = $class->next::method($hashref);

    if ($hashref->{QuantumViewEvents}) {
        my $data = $hashref->{QuantumViewEvents};
        set_implied_argument($data);
        $ret = {
            %$ret,
            in_object_array_if(events => 'SubscriptionEvents', 'Net::Async::Webservice::UPS::Response::QV::Event' ),
            subscriber_id => $data->{SubscriberID},
            pair_if(bookmark => $hashref->{Bookmark}),
        };
    }
    return $ret;
}

1;
