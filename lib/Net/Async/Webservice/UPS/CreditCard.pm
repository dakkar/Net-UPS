package Net::Async::Webservice::UPS::CreditCard;
use Moo;
use 5.010;
use Types::Standard qw(Str Int);
use Net::Async::Webservice::UPS::Types ':types';

has code => (
    is => 'ro',
    isa => CreditCardCode,
);

has type => (
    is => 'ro',
    isa => CreditCardType,
);

has number => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has expiration_year => (
    is => 'ro',
    isa => Int,
    required => 1,
);

has expiration_month => (
    is => 'ro',
    isa => Int,
    required => 1,
);

has security_code => (
    is => 'ro',
    isa => Str,
    required => 0,
);

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

sub type_for_code {
    my ($code) = @_;
    return $type_for_code{$code};
}

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

sub as_hash {
    my ($self) = @_;

    return {
        Type => $self->code,
        Number => $self->number,
        ExpirationDate => sprintf('%02d%02d',$self->expiration_month,$self->expiration_year),
        ( $self->security_code ? ( SecurityCode => $self->security_code ) : () ),
        Address => $self->address->as_hash('Ship'),
    };
}

sub cache_id { return $_[0]->code }

1;
