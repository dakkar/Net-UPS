package Net::Async::Webservice::UPS::Service;
use Moo;
use 5.010;
use Types::Standard qw(Str ArrayRef);
use Net::Async::Webservice::UPS::Types ':types';

# ABSTRACT: shipment service from UPS

=head1 DESCRIPTION

Instances of this class describe a particular shipping service. They
can be used as parameter to
L<Net::Async::Webservice::UPS/request_rate>, and are also used inside
L<Net::Async::Webservice::UPS::Response::Rate>, as returned by that
same method.

=attr C<code>

UPS service code, see
L<Net::Async::Webservice::UPS::Types/ServiceCode>. If you construct an
object passing only L</label>, the code corresponding to that label
will be used.

=cut

has code => (
    is => 'ro',
    isa => ServiceCode,
);

=attr C<label>

UPS service label, see
L<Net::Async::Webservice::UPS::Types/ServiceLabel>. If you construct
an object passing only L</code>, the label corresponding to that code
will be used.

=cut

has label => (
    is => 'ro',
    isa => ServiceLabel,
);

=attr C<total_charges>

If thes service has been returned by C<request_rate>, this is the
total charges for the shipment, equal to the sum of C<total_charges>
of all the rates in L</rates>.

=cut

has total_charges => (
    is => 'ro',
    isa => Measure,
    required => 0,
);

=attr C<rates>

If thes service has been returned by C<request_rate>, this is a
arrayref of L<Net::Async::Webservice::UPS::Rate> for each package.

=cut

has rates => (
    is => 'ro',
    isa => RateList,
    required => 0,
);

=attr C<rated_packages>

If thes service has been returned by C<request_rate>, this is a
arrayref of L<Net::Async::Webservice::UPS::Package> holding the rated
packages.

=cut

has rated_packages => (
    is => 'ro',
    isa => PackageList,
    required => 0,
);

=attr C<guaranteed_days>

If thes service has been returned by C<request_rate>, this is number
of guaranteed days in transit.

=cut

has guaranteed_days => (
    is => 'ro',
    isa => Str,
    required => 0,
);

my %code_for_label = (
    NEXT_DAY_AIR            => '01',
    '2ND_DAY_AIR'           => '02',
    GROUND                  => '03',
    WORLDWIDE_EXPRESS       => '07',
    WORLDWIDE_EXPEDITED     => '08',
    STANDARD                => '11',
    '3_DAY_SELECT'          => '12',
    '3DAY_SELECT'           => '12',
    NEXT_DAY_AIR_SAVER      => '13',
    NEXT_DAY_AIR_EARLY_AM   => '14',
    WORLDWIDE_EXPRESS_PLUS  => '54',
    '2ND_DAY_AIR_AM'        => '59',
    SAVER                   => '65',
    TODAY_EXPRESS_SAVER     => '86',
    TODAY_EXPRESS           => '85',
    TODAY_DEDICATED_COURIER => '83',
    TODAY_STANDARD          => '82',
);
my %label_for_code = reverse %code_for_label;

=func C<label_for_code>

  my $label = Net::Async::Webservice::UPS::Service::label_for_code($code);

I<Not a method>. Returns the UPS service label string for the given
service code.

=for Pod::Coverage
BUILDARGS

=cut

sub label_for_code {
    my ($code) = @_;
    return $label_for_code{$code};
}

around BUILDARGS => sub {
    my ($orig,$class,@etc) = @_;
    my $args = $class->$orig(@etc);
    if ($args->{code} and not $args->{label}) {
        $args->{label} = $label_for_code{$args->{code}};
    }
    elsif ($args->{label} and not $args->{code}) {
        $args->{code} = $code_for_label{$args->{label}};
    }
    return $args;
};

=method C<name>

Returns the L</label>, with underscores replaced by spaces.

=cut

sub name {
    my $self = shift;

    my $name = $self->label();
    $name =~ s/_/ /g;
    return $name;
}

=method C<cache_id>

Returns a string identifying this service.

=cut

sub cache_id { return $_[0]->code }

1;
