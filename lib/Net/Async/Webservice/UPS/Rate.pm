package Net::Async::Webservice::UPS::Rate;
use Moo;
use 5.010;
use Types::Standard qw(Str ArrayRef);
use Net::Async::Webservice::UPS::Types ':types';
use namespace::autoclean;

# ABSTRACT: shipment rate from UPS

=for Pod::Coverage BUILDARGS

=head1 DESCRIPTION

Objects of this class are usually only seen inside
L<Net::Async::Webservice::UPS::Response::Rate>, as returned by
L<Net::Async::Webservice::UPS/request_rate>.

=attr C<unit>

Either C<KGS> or C<LBS>, unit for the L</billing_weight>.

=cut

has unit => (
    is => 'ro',
    isa => WeightMeasurementUnit,
    required => 1,
);

=attr C<billing_weight>

The weight that was used to generate the price, not necessarily the
actual weight of the shipment or package.

=cut

has billing_weight => (
    is => 'ro',
    isa => Measure,
    required => 0,
);

=attr C<total_charges_currency>

Currency code for the L</total_charges>.

=cut

has total_charges_currency => (
    is => 'ro',
    isa => Currency,
    required => 1,
);

=attr C<total_charges>

Total rated cost of the shipment.

=cut

has total_charges => (
    is => 'ro',
    isa => Measure,
    required => 1,
);

=attr C<rated_package>

The package that was used to provide this rate.

=cut

has rated_package => (
    is => 'ro',
    isa => Package,
    required => 1,
);

=attr C<service>

I<Weak> reference to the L<Net::Async::Webservice::UPS::Service> this
rate is for. It's weak because the service holds references to rates,
and we really don't want cycles.

=cut

has service => (
    is => 'rwp',
    isa => Service,
    weak_ref => 1,
    required => 0,
);

=attr C<from>

Sender address for this shipment.

=cut

has from => (
    is => 'ro',
    isa => Address,
    required => 1,
);

=attr C<to>

Recipient address for this shipment.

=cut

has to => (
    is => 'ro',
    isa => Address,
    required => 1,
);

sub BUILDARGS {
    my ($class,@etc) = @_;
    my $hashref = $class->next::method(@etc);

    if ($hashref->{BillingWeight}) {
        return {
            billing_weight  => $hashref->{BillingWeight}{Weight},
            unit            => $hashref->{BillingWeight}{UnitOfMeasurement}{Code},
            total_charges   => $hashref->{TotalCharges}{MonetaryValue},
            total_charges_currency => $hashref->{TotalCharges}{CurrencyCode},
            weight          => $hashref->{Weight},
            rated_package   => $hashref->{rated_package},
            from            => $hashref->{from},
            to              => $hashref->{to},
        }
    }
    else {
        return $hashref,
    }
}

1;
