package Net::Async::Webservice::UPS::ReturnService;
use Moo;
use 5.010;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types ':types';

# ABSTRACT: shipment return service from UPS

=head1 DESCRIPTION

Instances of this class describe a particular shipping return service.

=attr C<code>

UPS service code, see
L<Net::Async::Webservice::UPS::Types/ReturnServiceCode>. If you
construct an object passing only L</label>, the code corresponding to
that label will be used.

=cut

has code => (
    is => 'ro',
    isa => ReturnServiceCode,
);

=attr C<label>

UPS service label, see
L<Net::Async::Webservice::UPS::Types/ReturnServiceLabel>. If you
construct an object passing only L</code>, the label corresponding to
that code will be used.

=cut

has label => (
    is => 'ro',
    isa => ReturnServiceLabel,
);

my %code_for_label = (
    PNM => '2',
    RS1 => '3',
    RS3 => '5',
    ERL => '8',
    PRL => '9',
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

=method C<cache_id>

Returns a string identifying this service.

=cut

sub cache_id { return $_[0]->code }

1;
