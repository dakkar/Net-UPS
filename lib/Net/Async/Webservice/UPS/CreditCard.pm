package Net::Async::Webservice::UPS::CreditCard;
use Moo;
use 5.010;
use Types::Standard qw(Str Int);
use Net::Async::Webservice::UPS::Types ':types';

# ABSTRACT: a credit card to pay UPS shipments with

=attr C<code>

Enum, L<Net::Async::Webservice::UPS::Types/CreditCardCode>, one of
C<01> C<03> C<04> C<05> C<06> C<07> C<08>. If not specified, it will
be derived from the L</type>.

=cut

has code => (
    is => 'ro',
    isa => CreditCardCode,
    required => 1,
);

=attr C<type>

Enum, L<Net::Async::Webservice::UPS::Types/CreditCardType>, one of
C<AMEX> C<Discover> C<MasterCard> C<Optima> C<VISA> C<Bravo>
C<Diners>. If not specified, it will be derived from the L</code>.

=cut

has type => (
    is => 'ro',
    isa => CreditCardType,
    required => 1,
);

=attr C<number>

Required string, the card number.

=cut

has number => (
    is => 'ro',
    isa => Str,
    required => 1,
);

=attr C<expiration_year>

Required integer, the year of expiration.

=cut

has expiration_year => (
    is => 'ro',
    isa => Int,
    required => 1,
);

=attr C<expiration_month>

Required integer, the month of expiration.

=cut

has expiration_month => (
    is => 'ro',
    isa => Int,
    required => 1,
);

=attr C<security_code>

Optional string, the card's security code (CVV2 or equivalent).

=cut

has security_code => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<address>

Required, instance of L<Net::Async::Webservice::UPS::Address>, the
billing address associated with the credit card.

=cut

has address => (
    is => 'ro',
    isa => Address,
    required => 1,
);

my %code_for_type = (
    AMEX => '01',
    Discover => '03',
    MasterCard => '04',
    Optima => '05',
    VISA => '06',
    Bravo => '07',
    Diners => '08',
);
my %type_for_code = reverse %code_for_type;

=func C<type_for_code>

  my $code = Net::Async::Webservice::UPS::CreditCard::type_for_code(2);

Function that returns the credit card type name given the code number.

=cut

sub type_for_code {
    my ($code) = @_;
    return $type_for_code{$code};
}

=for Pod::Coverage
BUILDARGS

=cut

around BUILDARGS => sub {
    my ($orig,$class,@etc) = @_;
    my $args = $class->$orig(@etc);
    if ($args->{code} and not $args->{type}) {
        $args->{type} = $type_for_code{$args->{code}};
    }
    elsif ($args->{type} and not $args->{code}) {
        $args->{code} = $code_for_type{$args->{type}};
    }
    return $args;
};

=method C<as_hash>

Returns a hashref that, when passed through L<XML::Simple>, will
produce the XML fragment needed in UPS requests to represent this
credit card.

=cut

sub as_hash {
    my ($self) = @_;

    return {
        Type => $self->code,
        Number => $self->number,
        ExpirationDate => sprintf('%02d%02d',$self->expiration_month,$self->expiration_year),
        ( $self->security_code ? ( SecurityCode => $self->security_code ) : () ),
        %{$self->address->as_hash('Ship')},
    };
}

=method C<cache_id>

Returns a string identifying this card.

=cut

sub cache_id { return $_[0]->number }

1;
