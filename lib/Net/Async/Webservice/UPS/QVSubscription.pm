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

# ABSTRACT: a UPS Quantum View subscription

=head1 DESCRIPTION

Instances of this class can be passed to
L<Net::Async::Webservice::UPS/qv_events> to specify what events you
want to retrieve.

=attr C<begin_date>

Optional L<DateTime> (with coercion from ISO 8601 strings), to only
retrieve events after this date.

=cut

has begin_date => (
    is => 'ro',
    isa => $dt,
    coerce => $dt->coercion
);

=attr C<end_date>

Optional L<DateTime> (with coercion from ISO 8601 strings), to only
retrieve events before this date.

=cut

has end_date => (
    is => 'ro',
    isa => $dt,
    coerce => $dt->coercion
);

=attr C<name>

Optional string, the name of a subscription.

=cut

has name => (
    is => 'ro',
    isa => Str,
);

=attr C<filename>

Optional string, the name of a Quantum View subscription file.

=cut

has filename => (
    is => 'ro',
    isa => Str,
);

=method C<as_hash>

Returns a hashref that, when passed through L<XML::Simple>, will
produce the XML fragment needed in UPS C<QVEvents> requests to
represent this subscription.

=cut

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
            $sr->{DateTimeRange}{"\u${f}DateTime"} =
                $date->strftime('%Y%m%d%H%M%S');
        }
    }

    return $sr;
}

1;
