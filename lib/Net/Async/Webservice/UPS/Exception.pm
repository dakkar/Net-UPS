package Net::Async::Webservice::UPS::Exception;
use Moo;
with 'Throwable','StackTrace::Auto';
use overload
  q{""}    => 'as_string',
  fallback => 1;

=head1 NAME

Net::Async::Webservice::UPS::Exception - exception classes for UPS

=head1 DESCRIPTION

These classes are based on L<Throwable> and L<StackTrace::Auto>. The
L</as_string> method should return something readable, with a full
stack trace.

=head1 Classes

=head2 C<Net::Async::Webservice::UPS::Exception>

Base class.

=cut

around _build_stack_trace_args => sub {
    my ($orig,$self) = @_;

    my $ret = $self->$orig();
    push @$ret, (
        no_refs => 1,
        respect_overload => 1,
        message => '',
        indent => 1,
    );

    return $ret;
};

=head3 Methods

=head4 C<as_string>

Generic "something bad happened", with stack trace.

=cut

sub as_string { "something bad happened at ". $_[0]->stack_trace->as_string }

{package Net::Async::Webservice::UPS::Exception::ConfigError;
 use Moo;
 extends 'Net::Async::Webservice::UPS::Exception';

=head2 C<Net::Async::Webservice::UPS::Exception::ConfigError>

exception thrown when the configuration file can't be parsed

=head3 Attributes

=head4 C<file>

The name of the configuration file.

=cut

 has file => ( is => 'ro', required => 1 );

=head3 Methods

=head4 C<as_string>

Mentions the file name, and gives the stack trace.

=cut

 sub as_string {
     my ($self) = @_;

     return 'Bad config file: %s, at %s',
         $self->file,
         $self->stack_trace->as_string;
 }
}

{package Net::Async::Webservice::UPS::Exception::BadPackage;
 use Moo;
 extends 'Net::Async::Webservice::UPS::Exception';

=head2 C<Net::Async::Webservice::UPS::Exception::BadPackage>

exception thrown when a package is too big for UPS to carry

=head3 Attributes

=head4 C<package>

The package object that's too big.

=cut

 has package => ( is => 'ro', required => 1 );

=head3 Methods

=head4 C<as_string>

Shows the size of the package, and the stack trace.

=cut

 sub as_string {
     my ($self) = @_;

     return sprintf 'Package size/weight not supported: %fx%fx%f %s %f %s, at %s',
         $self->package->length//'<undef>',
         $self->package->width//'<undef>',
         $self->package->height//'<undef>',
         $self->package->linear_unit,
         $self->package->weight//'<undef>',
         $self->package->weight_unit,
         $self->stack_trace->as_string;
 }
}

{package Net::Async::Webservice::UPS::Exception::HTTPError;
 use Moo;
 extends 'Net::Async::Webservice::UPS::Exception';
 use Try::Tiny;

=head2 C<Net::Async::Webservice::UPS::Exception::HTTPError>

exception thrown when the HTTP request fails

=head3 Attributes

=head4 C<request>

The request that failed.

=head4 C<response>

The failure response returned by the user agent

=cut

 has request => ( is => 'ro', required => 1 );
 has response => ( is => 'ro', required => 1 );

=head3 Methods

=head4 C<as_string>

Mentions the HTTP method, URL, response status line, and stack trace.

=cut

 sub as_string {
     my ($self) = @_;

     return sprintf 'Error %sing %s: %s, at %s',
         $self->request->method,$self->request->uri,
         (try {$self->response->status_line} catch {'no response'}),
         $self->stack_trace->as_string;
 }
}

{package Net::Async::Webservice::UPS::Exception::UPSError;
 use Moo;
 extends 'Net::Async::Webservice::UPS::Exception';

=head2 C<Net::Async::Webservice::UPS::Exception::UPSError>

exception thrown when UPS signals an error

=head3 Attributes

=head4 C<error>

The error data structure extracted from the UPS response.

=cut

 has error => ( is => 'ro', required => 1 );

=head3 Methods

=head4 C<as_string>

Mentions the description, severity, and code of the error, plus the
stack trace.

=cut

 sub as_string {
     my ($self) = @_;

     return sprintf 'UPS returned an error: %s, severity %s, code %d, at %s',
         $self->error->{ErrorDescription}//'<undef>',
         $self->error->{ErrorSeverity}//'<undef>',
         $self->error->{ErrorCode}//'<undef>',
         $self->stack_trace->as_string;
 }
}

1;
