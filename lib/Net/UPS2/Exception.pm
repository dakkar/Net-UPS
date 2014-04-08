package Net::UPS2::Exception;
use strict;
use warnings;
use Moo;
with 'Throwable','StackTrace::Auto';
use overload
  q{""}    => 'as_string',
  fallback => 1;

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

sub as_string { "something bad happened at ". $_[0]->stack_trace->as_string }

{package Net::UPS2::Exception::ConfigError;
 use strict;
 use warnings;
 use Moo;
 extends 'Net::UPS2::Exception';

 has file => ( is => 'ro', required => 1 );

 sub as_string {
     my ($self) = @_;

     return 'Bad config file: %s, at %s',
         $self->file,
         $self->stack_trace->as_string;
 }
}

{package Net::UPS2::Exception::BadPackage;
 use strict;
 use warnings;
 use Moo;
 extends 'Net::UPS2::Exception';

 has package => ( is => 'ro', required => 1 );

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

{package Net::UPS2::Exception::HTTPError;
 use strict;
 use warnings;
 use Moo;
 extends 'Net::UPS2::Exception';

 has request => ( is => 'ro', required => 1 );
 has response => ( is => 'ro', required => 1 );

 sub as_string {
     my ($self) = @_;

     return sprintf 'Error %sing %s: %s, at %s',
         $self->request->method,$self->request->uri,
         $self->response->status_line,
         $self->stack_trace->as_string;
 }
}

{package Net::UPS2::Exception::UPSError;
 use strict;
 use warnings;
 use Moo;
 extends 'Net::UPS2::Exception';

 has error => ( is => 'ro', required => 1 );

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
