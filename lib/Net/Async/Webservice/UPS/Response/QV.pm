package Net::Async::Webservice::UPS::Response::QV;
use Moo;
use Types::Standard qw(Str ArrayRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils ':all';
use namespace::autoclean;

extends 'Net::Async::Webservice::UPS::Response';

has subscriber_id => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has events => (
    is => 'ro',
    isa => ArrayRef[QVEvent],
    required => 0,
);

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
