package Net::Async::Webservice::UPS::Label;
use Moo;
use 5.010;
use Net::Async::Webservice::UPS::Types qw(:types);

has code => (
    is => 'ro',
    isa => ImageType,
    required => 1,
);

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
