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
        require Net::Async::Webservice::UPS::Response::QV::Event;
        my $data = $hashref->{QuantumViewEvents};
        my $events = $data->{SubscriptionEvents};
        if (ref($events) ne 'ARRAY') { $events = [ $events ] }
        $ret = {
            %$ret,
            events => [ map {
                Net::Async::Webservice::UPS::Response::QV::Event->new($_)
            } @{$events} ],
            subscriber_id => $data->{SubscriberID},
            pair_if(bookmark => $hashref->{Bookmark}),
        };
    }
    return $ret;
}

1;
