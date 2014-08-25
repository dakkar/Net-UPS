package Net::Async::Webservice::UPS::Exception;
use strict;

=head1 NAME

Net::Async::Webservice::UPS::Exception - exception classes for UPS

=head1 DESCRIPTION

These classes are based on L<Throwable> and L<StackTrace::Auto>. The
L</as_string> method should return something readable, with a full
stack trace. Their base class is
L<Net::Async::Webservice::Common::Exception>.

=head1 Classes

=cut

{package Net::Async::Webservice::UPS::Exception::BadPackage;
 use Moo;
 extends 'Net::Async::Webservice::Common::Exception';
 use namespace::autoclean;

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

{package Net::Async::Webservice::UPS::Exception::UPSError;
 use Moo;
 extends 'Net::Async::Webservice::Common::Exception';
 use namespace::autoclean;

=head2 C<Net::Async::Webservice::UPS::Exception::UPSError>

exception thrown when UPS signals an error

=head3 Attributes

=head4 C<error>

The error data structure extracted from the UPS response.

=cut

 has error => ( is => 'ro', required => 1 );

=head3 Methods

=head4 C<error_description>

=head4 C<error_severity>

=head4 C<error_code>

=head4 C<error_location>

=head4 C<retry_seconds>

These just return the similarly-named fields from inside L</error>:
C<ErrorDescription>, C<ErrorSeverity>, C<ErrorCode>, C<ErrorLocation>,
C<MinimumRetrySeconds>.

=cut

 sub error_description { $_[0]->error->{ErrorDescription} }
 sub error_severity { $_[0]->error->{ErrorSeverity} }
 sub error_code { $_[0]->error->{ErrorCode} }
 sub error_location { $_[0]->error->{ErrorLocation} }
 sub retry_seconds { $_[0]->error->{MinimumRetrySeconds} }

 sub _error_location_str {
     my ($self) = @_;
     my $el = $self->error_location;
     if ($el->{ErrorLocationElementName}) {
         return "element ".$el->{ErrorLocationElementName};
     }
     elsif ($el->{ErrorLocationAttributeName}) {
         return "attribute ".$el->{ErrorLocationAttributeName};
     }
     else {
         return;
     }
 }

=head4 C<as_string>

Mentions the description, severity, and code of the error, plus the
stack trace.

=cut

 sub as_string {
     my ($self) = @_;

     return sprintf 'UPS returned an error: %s, severity %s, code %s, location %s, at %s',
         $self->error_description//'<undef>',
         $self->error_severity//'<undef>',
         $self->error_code//'<undef>',
         $self->_error_location_str//'<undef>',
         $self->stack_trace->as_string;
 }
}

1;
