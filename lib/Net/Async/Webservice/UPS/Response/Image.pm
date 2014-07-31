package Net::Async::Webservice::UPS::Response::Image;
use Moo;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types qw(:types);
use MIME::Base64;
use namespace::autoclean;

has format => (
    is => 'ro',
    isa => ImageType,
    required => 0,
);

has data => (
    is => 'ro',
    isa => Str,
    required => 0,
);

sub from_hash {
    my ($class,$hash) = @_;

    my ($format_key) = grep {/ImageFormat$/} keys %$hash;

    return $class->new({
        format => $hash->{$format_key}{Code},
        data => decode_base64($hash->{GraphicImage}),
    });
}

1;
