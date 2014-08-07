package Net::Async::Webservice::UPS::Label;
use Moo;
use 5.010;
use Net::Async::Webservice::UPS::Types qw(:types);

# ABSTRACT: a label for a shipment request

=head1 DESCRIPTION

This class is to be used in
L<Net::Async::Webservice::UPS/ship_confirm> to specify what kind of
label you want in the response.

=attr C<code>

Required, enum of type
L<Net::Async::Webservice::UPS::Types/ImageType>, one of C<EPL>,
C<ZPL>, C<SPL>, C<STARPL>, C<GIF>.

=cut

has code => (
    is => 'ro',
    isa => ImageType,
    required => 1,
);

=method C<as_hash>

Returns a hashref that, when passed through L<XML::Simple>, will
produce the XML fragment needed in UPS requests to represent this
label. C<GIF> labels get a C<UserAgent> value of C<Mozilla/4.5>, and
others get a C<LabelStockSize> of 4" by 6": that's what I think the
UPS documentation say is required.

=cut

sub as_hash {
    my ($self) = @_;

    return {
        LabelPrintMethod => {
            Code => $self->code,
        },
        ( $self->code eq 'GIF' ? (
            HTTPUserAgent => 'Mozilla/4.5',
            LabelImageFormat => 'GIF',
        ) : (
            LabelStockSize => {
                Height => 4,
                Width => 6,
            },
        ) ),
    };
}

1;
