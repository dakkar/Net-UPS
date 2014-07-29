package Net::Async::Webservice::UPS::Label;
use Moo;
use 5.010;
use Types::Standard qw(Str Int Enum);

has code => (
    is => 'ro',
    isa => Enum[qw(EPL ZPL SPL STARPL GIF)],
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
