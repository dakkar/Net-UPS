package Net::Async::Webservice::UPS::Response::QV::File;
use Moo;
use Types::Standard qw(Str ArrayRef HashRef);
use Net::Async::Webservice::UPS::Types qw(:types);
use Net::Async::Webservice::UPS::Response::Utils ':all';
use namespace::autoclean;

# ABSTRACT: a Quantum View "file"

=for Pod::Coverage BUILDARGS

=head1 DESCRIPTION

Object representing the
C<QuantumViewEvents/SubscriptionEvents/SubscriptionFile> elements in
the Quantum View response. Attribute descriptions come from the
official UPS documentation.

=attr C<filename>

File name belonging to specific subscription requested by user,
usually in form of C<YYMMDD_HHmmssnnn>.

=cut

has filename => (
    is => 'ro',
    isa => Str,
    required => 1,
);

=attr C<status>

Hashref, with keys:

=for :list
= C<Code>
required, status types of subscription file; valid values are: C<R> – Read, C<U> - Unread
= C<Description>
optional, description of the status

=cut

has status => (
    is => 'ro',
    isa => HashRef,
    required => 0,
);

=attr C<origins>

Optional, array ref of L<Net::Async::Webservice::UPS::Response::QV::Origin>.

=cut

has origins => (
    is => 'ro',
    isa => ArrayRef[QVOrigin],
    required => 0,
);

=attr C<generics>

Optional, array ref of L<Net::Async::Webservice::UPS::Response::QV::Generic>.

=cut

has generics => (
    is => 'ro',
    isa => ArrayRef[QVGeneric],
    required => 0,
);

=attr C<manifests>

Optional, array ref of L<Net::Async::Webservice::UPS::Response::QV::Manifest>.

B<Never set in this version>. Parsing manifests is complicated, it
will be maybe implemented in a future version.

=cut

has manifests => (
    is => 'ro',
    isa => ArrayRef[QVManifest],
    required => 0,
);

=attr C<deliveries>

Optional, array ref of L<Net::Async::Webservice::UPS::Response::QV::Delivery>.

=cut

has deliveries => (
    is => 'ro',
    isa => ArrayRef[QVDelivery],
    required => 0,
);

=attr C<exceptions>

Optional, array ref of L<Net::Async::Webservice::UPS::Response::QV::Exception>.

=cut

has exceptions => (
    is => 'ro',
    isa => ArrayRef[QVException],
    required => 0,
);

sub BUILDARGS {
    my ($class,$hashref) = @_;
    if (@_>2) { shift; $hashref={@_} };

    if ($hashref->{FileName}) {
        set_implied_argument($hashref);

        return {
            in_if(filename => 'FileName'),
            in_if(status => 'StatusType'),
            in_object_array_if(origins=>'Origin','Net::Async::Webservice::UPS::Response::QV::Origin'),
            in_object_array_if(generics=>'Generic','Net::Async::Webservice::UPS::Response::QV::Generic'),
            in_object_array_if(deliveries=>'Delivery','Net::Async::Webservice::UPS::Response::QV::Delivery'),
            # Manifests are not yet supported
            #in_object_array_if(manifests=>'Manifest','Net::Async::Webservice::UPS::Response::QV::Manifest'),
            in_object_array_if(exceptions=>'Exception','Net::Async::Webservice::UPS::Response::QV::Exception'),
        };
    }
    return $hashref;
}

1;
