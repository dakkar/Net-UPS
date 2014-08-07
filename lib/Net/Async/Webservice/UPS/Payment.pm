package Net::Async::Webservice::UPS::Payment;
use Moo;
use 5.010;
use Types::Standard qw(Str Bool Enum);
use Net::Async::Webservice::UPS::Types ':types';
use namespace::autoclean;

# ABSTRACT: a payment method for UPS shipments

=attr C<method>

Enum, one of C<prepaid> C<third_party> C<freight_collect>. Defaults to
C<prepaid>.

=cut

has method => (
    is => 'ro',
    isa => Enum[qw(prepaid third_party freight_collect)],
    default => 'prepaid',
);

=attr C<account_number>

A UPS account number to bill, required for C<third_party> and
C<freight_collect> payment methods. For C<prepaid>, either this or
L</credit_card> must be set.

=cut

has account_number => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<credit_card>

A credit card (instance of L<Net::Async::Webservice::UPS::CreditCard>)
to bill.  For C<prepaid>, either this or L</account_number> must be
set.

=cut

has credit_card => (
    is => 'ro',
    isa => CreditCard,
    required => 0,
);

=attr C<address>

An address (instance of L<Net::Async::Webservice::UPS::Address>),
required for C<third_party> and C<freight_collect> payment methods.

=cut

has address => (
    is => 'ro',
    isa => Address,
    required => 0,
);

=for Pod::Coverage
BUILDARGS

=cut

around BUILDARGS => sub {
    my ($orig,$class,@etc) = @_;
    my $args = $class->$orig(@etc);

    if ($args->{method} eq 'prepaid') {
        if (not ($args->{credit_card} or $args->{account_number})) {
            require Carp;
            Carp::croak "account_number or credit_card required when payment method is 'prepaid'";
        }
    }
    elsif ($args->{method} eq 'third_party') {
        if (not ($args->{account_number} and $args->{address})) {
            require Carp;
            Carp::croak "account_number and address required when payment method is 'third_party'";
        }
    }
    elsif ($args->{method} eq 'freight_collect') {
        if (not ($args->{account_number} and $args->{address})) {
            require Carp;
            Carp::croak "account_number required when payment method is 'freight_collect'";
        }
    }

    return $args;
};

=method C<as_hash>

Returns a hashref that, when passed through L<XML::Simple>, will
produce the XML fragment needed in UPS requests to represent this
payment method.

=cut

sub as_hash {
    my ($self) = @_;

    return {
        ($self->method eq 'prepaid') ? ( Prepaid => {
            BillShipper => {
                ( $self->account_number ? ( AccountNumber => $self->account_number ) :
                ( $self->credit_card ? ( CreditCard => $self->credit_card->as_hash ) :
                () ) ),
            },
        } ) :
        ($self->method eq 'third_party') ? ( BillThirdParty => {
            BillThirdPartyShipper => {
                AccountNumber => $self->account_number,
                ThirdPartyShipper => $self->address->as_hash('Ship'),
            },
        } ) :
        ($self->method eq 'freight_collect') ? ( FreightCollect => {
            BillReceiver => {
                AccountNumber => $self->account_number,
                %{$self->address->as_hash('Ship')},
            },
        } ) : ()
    };
}

1;
