package Net::Async::Webservice::UPS::Response::ShipmentAccept;
use Moo;
use Types::Standard qw(Str ArrayRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils ':all';
use List::AllUtils 'pairwise';
use namespace::autoclean;

extends 'Net::Async::Webservice::UPS::Response::ShipmentBase';

# ABSTRACT: UPS response to a ShipAccept request

=head1 DESCRIPTION

This class is returned by
L<Net::Async::Webservice::UPS/ship_accept>. It's a sub-class of
L<Net::Async::Webservice::UPS::Response::ShipmentBase>.

=attr C<pickup_request_number>

Not sure what this means.

=cut

has pickup_request_number => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<control_log>

An instance of L<Net::Async::Webservice::UPS::Response::Image>, not
sure what this means.

=cut

has control_log => (
    is => 'ro',
    isa => Image,
    required => 0,
);

=attr C<package_results>

Array ref of L<Net::Async::Webservice::UPS::Response::PackageResult>.

=cut

has package_results => (
    is => 'ro',
    isa => ArrayRef[PackageResult],
    required => 0,
);

sub BUILDARGS {
    my ($class,$hashref) = @_;
    if (@_>2) { shift; $hashref={@_} };

    my $ret = $class->next::method($hashref);

    if ($hashref->{ShipmentResults}) {
        require Net::Async::Webservice::UPS::Response::PackageResult;

        my $results = $hashref->{ShipmentResults};
        my $weight = $results->{BillingWeight};
        my $charges = $results->{ShipmentCharges};

        $ret = {
            %$ret,
            unit => $weight->{UnitOfMeasurement}{Code},
            billing_weight => $weight->{Weight},
            currency => $charges->{TotalCharges}{CurrencyCode},
            service_option_charges => $charges->{ServiceOptionsCharges}{MonetaryValue},
            transportation_charges => $charges->{TransportationCharges}{MonetaryValue},
            total_charges => $charges->{TotalCharges}{MonetaryValue},
            shipment_identification_number => $results->{ShipmentIdentificationNumber},
            pair_if( pickup_request_number => $results->{PickupRequestNumber} ),
            img_if( control_log => $results->{ControlLogReceipt} ),
            package_results => [ pairwise {
                my ($pr,$pack) = ($a, $b);

                Net::Async::Webservice::UPS::Response::PackageResult->new({
                    %$pr,
                    package => $pack,
                });
            } @{$results->{PackageResults}//[]},@{$hashref->{packages}//[]} ],
        };
    }

    return $ret;
}

1;
