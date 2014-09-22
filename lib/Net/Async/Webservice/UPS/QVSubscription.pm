package Net::Async::Webservice::UPS::QVSubscription;
use Moo;
use 5.010;
use Types::Standard qw(Str Int Bool StrictNum);
use Types::DateTime
    DateTime => { -as => 'DateTimeT' },
    Format => { -as => 'DTFormat' };
use Net::Async::Webservice::UPS::Types ':types';
use namespace::autoclean;

my $dt = DateTimeT->plus_coercions(DTFormat['ISO8601']);

has begin_date => (
    is => 'ro',
    isa => $dt,
    coerce => $dt->coercion
);

has end_date => (
    is => 'ro',
    isa => $dt,
    coerce => $dt->coercion
);

has name => (
    is => 'ro',
    isa => Str,
);

has filename => (
    is => 'ro',
    isa => Str,
);

sub as_hash {
    my ($self) = @_;

    my $sr = {
        ( $self->name ? ( Name => $self->name ) : () ),
        ( $self->filename ? ( FileName => $self->filename ) : () ),
    };

    for my $f (qw(begin end)){
        my $method = "${f}_date";
        if ($self->$method) {
            my $date = $self->$method->clone->set_time_zone('UTC');
            $sr->{DateTimeRange}{"\U${f}\EDateTime"} =
                $date->strftime('%Y%m%d%H%M%S');
        }
    }

    return $sr;
}

1;
