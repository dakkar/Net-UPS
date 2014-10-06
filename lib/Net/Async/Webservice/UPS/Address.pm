package Net::Async::Webservice::UPS::Address;
use Moo;
use 5.010;
use Types::Standard qw(Str Int Bool StrictNum);
use Net::Async::Webservice::UPS::Types ':types';
use Net::Async::Webservice::UPS::Response::Utils ':all';
use namespace::autoclean;

# ABSTRACT: an address for UPS

=for Pod::Coverage BUILDARGS

=attr C<city>

String with the name of the city, optional.

=cut

has city => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<postal_code>

String with the post code of the address, usually required.

=cut

has postal_code => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<postal_code_extended>

String with the extended post code of the address, optional. If a
postcode matching C<< \d+-\d+ >> is passed in to the constructor, the
first group of digits is assigned to L</postal_code> and the second
one to L</postal_code_extended>.

=cut

has postal_code_extended => (
    is => 'ro',
    isa => Str,
    required => 0,
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

=attr C<name>

String with the recipient name, optional.

=cut

has name => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<building_name>

String with the building name, optional.

=cut

has building_name => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<address>

String with the first line of the address, optional.

=cut

has address => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<address2>

String with the second line of address, optional.

=cut

has address2 => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=attr C<address3>

String with the third line of the address, optional.

=cut

has address3 => (
    is => 'ro',
    isa => Str,
    required => 0,
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
address. Takes one parameter, either C<'AV'> or C<'XAV'>, to select
which representation to use (C<'XAV'> is the "street level validation"
variant).

=cut

sub as_hash {
    my ($self, $shape) = @_;
    $shape //= 'AV';

    set_implied_argument($self);

    if ($shape eq 'AV') {
        return {
            Address => {
                CountryCode => $self->country_code || "US",
                PostalCode  => $self->postal_code,
                out_if(City=>'city'),
                out_if(StateProvinceCode=>'state'),
                ( $self->is_residential ? ( ResidentialAddressIndicator => undef ) : () ),
            }
        };
    }
    elsif ($shape eq 'XAV') {
        return {
            AddressKeyFormat => {
                CountryCode => $self->country_code || "US",
                PostcodePrimaryLow  => $self->postal_code,
                out_if(PostcodeExtendedLow=>'postal_code_extended'),
                out_if(ConsigneeName=>'name'),
                out_if(BuildingName=>'building_name'),
                AddressLine  => [
                    ( $self->address ? $self->address : () ),
                    ( $self->address2 ? $self->address2 : () ),
                    ( $self->address3 ? $self->address3 : () ),
                ],
                out_if(PoliticalDivision1=>'state'),
                out_if(PoliticalDivision2=>'city'),
            }
        }
    }
    elsif ($shape eq 'Ship') {
        return {
            Address => {
                CountryCode => $self->country_code || "US",
                PostalCode  => $self->postal_code,
                out_if(AddressLine1=>'address'),
                out_if(AddressLine2=>'address2'),
                out_if(AddressLine3=>'address3'),
                out_if(City=>'city'),
                out_if(StateProvinceCode=>'state'),
            }
        }
    }
    else {
        die "bad address as_hash shape $shape";
    }
}

sub BUILDARGS {
    my ($class,@etc) = @_;
    my $hashref = $class->next::method(@etc);

    my $data = $hashref->{Address} || $hashref->{AddressKeyFormat} || $hashref->{AddressArtifactFormat};

    if (not $data) {
        if ($hashref->{postal_code}
                and not defined $hashref->{postal_code_extended}
                    and $hashref->{postal_code} =~ m{\A(\d+)-(\d+)\z}) {
            $hashref->{postal_code} = $1;
            $hashref->{postal_code_extended} = $2;
        }
        my @undef_k = grep {not defined $hashref->{$_} } keys %$hashref;
        delete @$hashref{@undef_k};
        return $hashref;
    }

    set_implied_argument($data);

    return {
        country_code => 'US', # default,
        pair_if(quality=>$hashref->{Quality}),
        in_if(country_code=>'CountryCode'),
        in_if(postal_code=>'PostalCode'),
        in_if(postal_code=>'PostcodePrimaryLow'),
        in_if(city=>'City'),
        in_if(city=>'PoliticalDivision2'),
        in_if(state=>'StateProvinceCode'),
        in_if(state=>'PoliticalDivision1'),
        in_if(postal_code_extended=>'PostcodeExtendedLow'),
        in_if(name=>'ConsigneeName'),
        in_if(building_name=>'BuildingName'),
        in_if(address=>'AddressLine1'),
        in_if(address2=>'AddressLine2'),
        in_if(address3=>'AddressLine3'),

        ( exists $data->{ResidentialAddressIndicator} ? ( is_residential => 1 ) : () ),
        ( exists $data->{AddressClassification} ? ( is_residential => $data->{AddressClassification}{Code} eq 2 ? 1 : 0 ) : () ),

        ( $data->{StreetName} || $data->{StreetNumberLow} || $data->{StreetType} ? (
            address => join(
                ' ',grep { defined }
                    @{$data}{qw(StreetNumberLow StreetName {StreetType)})
                ) : () ),

        ( ref($data->{AddressLine}) eq 'ARRAY' ? (
            ( $data->{AddressLine}[0] ? ( address => $data->{AddressLine}[0] ) : () ),
            ( $data->{AddressLine}[1] ? ( address2 => $data->{AddressLine}[1] ) : () ),
            ( $data->{AddressLine}[2] ? ( address3 => $data->{AddressLine}[2] ) : () ),
        ) : () ),
    };
}

=method C<cache_id>

Returns a string identifying this address.

=cut

sub cache_id {
    my ($self) = @_;
    return join ':',
        $self->name||'',
        $self->building_name||'',
        $self->address||'',
        $self->address2||'',
        $self->address3||'',
        $self->country_code,
        $self->state||'',
        $self->city||'',
        $self->postal_code,
        $self->postal_code_extended||'',
}

1;
