package Net::Async::Webservice::UPS::Contact;
use Moo;
use 5.010;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types ':types';
use Net::Async::Webservice::UPS::Address;

has name => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has company_name => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has attention_name => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has phone_number => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has email_address => (
    is => 'ro',
    isa => Str,
    required => 0,
);

has address => (
    is => 'ro',
    isa => Address,
    required => 1,
);


sub as_hash {
    my ($self,$shape) = @_;

    $shape ||= 'Ship';

    return {
        ( $self->name ? ( Name => $self->name ) : () ),
        ( $self->company_name ? ( CompanyName => $self->company_name ) : () ),
        ( $self->attention_name ? ( AttentionName => $self->attention_name ) : () ),
        ( $self->phone_number ? ( PhoneNumber => $self->phone_number ) : () ),
        ( $self->email_address ? ( EmailAddress => $self->email_address ) : () ),
        %{ $self->address->as_hash($shape) },
    };
}

sub cache_id {
    my ($self) = @_;

    return $self->address->cache_id;
}

1;
