package Net::Async::Webservice::UPS::Contact;
use Moo;
use 5.010;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types ':types';
use Net::Async::Webservice::UPS::Address;

# ABSTRACT: a "contact" for UPS

=head1 DESCRIPTION

A contact is someone you send a shipment to, or that you want to pick
up a shipment from.

=attr C<name>

Optional string, the contact's name.

=cut

has name => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<company_name>

Optional string, the contact's company name.

=cut

has company_name => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<attention_name>

Optional string, the name of the person to the attention of whom UPS
should bring the shipment.

=cut

has attention_name => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<phone_number>

Optional string, the contact's phone number.

=cut

has phone_number => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<email_address>

Optional string, the contact's email address.

=cut

has email_address => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<address>

Required L<Net::Async::Webservice::UPS::Address> object, the contact's
address.

=cut

has address => (
    is => 'ro',
    isa => Address,
    required => 1,
);

=method C<as_hash>

Returns a hashref that, when passed through L<XML::Simple>, will
produce the XML fragment needed in UPS requests to represent this
contact.

=cut

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

=method C<cache_id>

Returns a string identifying this contact.

=cut

sub cache_id {
    my ($self) = @_;

    return $self->address->cache_id;
}

1;
