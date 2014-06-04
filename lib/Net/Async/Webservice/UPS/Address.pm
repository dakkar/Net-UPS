package Net::Async::Webservice::UPS::Address;
use Moo;
use 5.10.0;
use Types::Standard qw(Str Int Bool StrictNum);
use Net::Async::Webservice::UPS::Types ':types';

# ABSTRACT: an address for UPS

=attr C<city>

String with the name of the city, optional.

=cut

has city => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<postal_code>

String with the post code of the address, required.

=cut

has postal_code => (
    is => 'ro',
    isa => Str,
    required => 1,
);

=attr C<state>

String with the name of the state, optional.

=cut

has state => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<country_code>

String with the 2 letter country code, optional (defaults to C<US>).

=cut

has country_code => (
    is => 'ro',
    isa => Str,
    required => 0,
    default => 'US',
);

=attr C<is_residential>

Boolean, indicating whether this address is residential. Optional.

=cut

has is_residential => (
    is => 'ro',
    isa => Bool,
    required => 0,
);

=attr C<quality>

This should only be set in objects that are returned as part of a
L<Net::Async::Webservice::UPS::Response::Address>. It's a float
between 0 and 1 expressing how good a match this address is for the
one provided.

=cut

has quality => (
    is => 'ro',
    isa => StrictNum,
    required => 0,
);

=method C<is_exact_match>

True if L</quality> is 1. This method exists for compatibility with
L<Net::UPS::Address>.

=cut

sub is_exact_match {
    my $self = shift;
    return unless $self->quality();
    return ($self->quality == 1);
}

=method C<is_very_close_match>

True if L</quality> is >= 0.95. This method exists for compatibility
with L<Net::UPS::Address>.

=cut

sub is_very_close_match {
    my $self = shift;
    return unless $self->quality();
    return ($self->quality >= 0.95);
}

=method C<is_close_match>

True if L</quality> is >=0.9. This method exists for compatibility
with L<Net::UPS::Address>.

=cut

sub is_close_match {
    my $self = shift;
    return unless $self->quality();
    return ($self->quality >= 0.90);
}

=method C<is_possible_match>

True if L</quality> is >= 0.9 (yes, the same as
L</is_close_match>). This method exists for compatibility with
L<Net::UPS::Address>.

=cut

sub is_possible_match {
    my $self = shift;
    return unless $self->quality();
    return ($self->quality >= 0.90);
}

=method C<is_poor_match>

True if L</quality> is <= 0.69. This method exists for compatibility
with L<Net::UPS::Address>.

=cut

sub is_poor_match {
    my $self = shift;
    return unless $self->quality();
    return ($self->quality <= 0.69);
}

=method C<as_hash>

Returns a hashref that, when passed through L<XML::Simple>, will
produce the XML fragment needed in UPS requests to represent this
address.

=cut

sub as_hash {
    my $self = shift;

    my %data = (
        Address => {
            CountryCode => $self->country_code || "US",
            PostalCode  => $self->postal_code,
            ( $self->city ? ( City => $self->city) : () ),
            ( $self->state ? ( StateProvinceCode => $self->state) : () ),
            ( $self->is_residential ? ( ResidentialAddressIndicator => undef ) : () ),
        }
    );

    return \%data;
}

=method C<cache_id>

Returns a string identifying this address.

=cut

sub cache_id {
    my ($self) = @_;
    return join ':',
        $self->country_code,
        $self->state||'',
        $self->city||'',
        $self->postal_code,
}

1;
