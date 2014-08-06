package Net::Async::Webservice::UPS::Payment;
use Moo;
use 5.010;
use Types::Standard qw(Str Bool Enum);
use Net::Async::Webservice::UPS::Types ':types';

has method => (
    is => 'ro',
    isa => Enum[qw(prepaid third_party freight_collect)],
    default => 'prepaid',
);

has account_number => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has credit_card => (
    is => 'ro',
    isa => CreditCard,
    required => 0,
    coerce => CreditCard->coercion,
);

has address => (
    is => 'ro',
    isa => Address,
    required => 0,
);

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
                ThirdPartyShipper => {
                    Address => $self->address->as_hash('Ship'),
                },
            },
        } ) :
        ($self->method eq 'freight_collect') ? ( FreightCollect => {
            BillReceiver => {
                AccountNumber => $self->account_number,
                ( $self->address ? ( Address => $self->address->as_hash('Ship'), ) : () ),
            },
        } ) : ()
    };
}

1;
