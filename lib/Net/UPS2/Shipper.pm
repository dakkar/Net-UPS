package Net::UPS2::Shipper;
use strict;
use warnings;
use Moo;
use 5.10.0;
use Types::Standard qw(Str Int Bool StrictNum);
use Net::UPS2::Types ':types';
extends 'Net::UPS2::Address';

has name => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has company_name => (
    is => 'ro',
    isa => Str,
);

has attention_name => (
    is => 'ro',
    isa => Str,
);

has phone_number => (
    is => 'ro',
    isa => Str,
);

has email_address => (
    is => 'ro',
    isa => Str,
);

sub as_hash {
    my $self = shift;

    my $data = $self->next::method;
    $data->{Name} = $self->name;
    $data->{CompanyName} = $self->company_name if $self->company_name;
    $data->{AttentionName} = $self->attention_name if $self->attention_name;
    $data->{PhoneNumber} = $self->phone_number if $self->phone_number;
    $data->{EMailAddress} = $self->email_address if $self->email_address;

    return $data;
}

1;
