package Net::Async::Webservice::UPS::Response::Image;
use Moo;
use Types::Standard qw(Str);
use Net::Async::Webservice::UPS::Types qw(:types);
use MIME::Base64;
use namespace::autoclean;

# ABSTRACT: an image in a UPS response

=attr C<format>

Enum of type L<Net::Async::Webservice::UPS::Types/ImageType>, one of
C<EPL>, C<ZPL>, C<SPL>, C<STARPL>, C<GIF>.

=cut

has format => (
    is => 'ro',
    isa => ImageType,
    required => 0,
);

=attr C<data>

String of bytes, containing the actual image data. You can pass the
argument C<base64_data> to the constructor instead of C<data>, to have
it decoded automatically.

=cut

has data => (
    is => 'ro',
    isa => Str,
    required => 0,
);

=for Pod::Coverage
BUILDARGS

=cut

around BUILDARGS => sub {
    my ($orig,$class,@etc) = @_;
    my $args = $class->$orig(@etc);

    if (my $b64 = delete $args->{base64_data}) {
        $args->{data} = decode_base64($b64);
    }

    return $args;
};

=method C<BUILDARGS>

  my $miage = Net::Async::Webservice::UPS::Response::Image
                ->new($piece_of_ups_response);

If you call the constructor with a hashref with at least a key
matching C</ImageFormat$/> and a key of C<GraphicImage>, this will
extract the image.

=cut

sub BUILDARGS {
    my ($class,$hash) = @_;

    my ($format_key) = grep {/ImageFormat$/} keys %$hash;

    if ($format_key) {
        return {
            format => $hash->{$format_key}{Code},
            base64_data => $hash->{GraphicImage},
        };
    }
    else {
        return $hash;
    }
}

1;
