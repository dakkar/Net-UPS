package Net::Async::Webservice::UPS::Response::QV::Event;
use Moo;
use 5.010;
use Types::Standard qw(Str ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils ':all';
use Types::DateTime DateTime => { -as => 'DateTimeT' };
use DateTime::Format::Strptime;
use namespace::autoclean;

has name => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has number => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has status => (
    is => 'ro',
    isa => HashRef,
    required => 1,
);

has files => (
    is => 'ro',
    isa => ArrayRef[QVFile],
    required => 1,
);

has begin_date => (
    is => 'ro',
    isa => DateTimeT,
    required => 0,
);

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
