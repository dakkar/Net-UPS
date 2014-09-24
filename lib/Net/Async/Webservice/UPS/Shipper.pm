package Net::Async::Webservice::UPS::Shipper;
use Moo;
use 5.010;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types ':types';
extends 'Net::Async::Webservice::UPS::Contact';
use namespace::autoclean;

# ABSTRACT: a contact with an account number

=head1 DESCRIPTION

A shipper is eithre the originator of a shipment, or someone to whose
account the shipment is billed. This class subclasses
L<Net::Async::Webservice::UPS::Contact> and adds the
L</account_number> field.

=attr C<account_number>

Optional string, the UPS account number for this shipper.

=cut

has account_number => (
    is => 'ro',
    isa => Str,
);

=method C<as_hash>

Returns a hashref that, when passed through L<XML::Simple>, will
produce the XML fragment needed in UPS requests to represent this
shipper.

=cut

sub as_hash {
    my ($self,$shape) = @_;

    my $ret = $self->next::method($shape);
    if ($self->account_number) {
        $ret->{ShipperNumber} = $self->account_number;
    }
    return $ret;
}

=method C<cache_id>

Returns a string identifying this shipper.

=cut

sub cache_id {
    my ($self) = @_;

    return join ':',
        ($self->account_number||''),
        $self->address->cache_id;
}

1;
