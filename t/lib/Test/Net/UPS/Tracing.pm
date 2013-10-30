package Test::Net::UPS::Tracing;
use strict;
use warnings;
use parent 'LWP::UserAgent';
use Time::HiRes 'gettimeofday';
use File::Temp 'tempfile';

sub request {
    my ($self,$request) = @_;

    my ($sec,$usec) = gettimeofday;

    my ($fh,$filename) = tempfile("net-ups-$sec-$usec-XXXX");

    printf $fh "POST %s\n\n%s\n",
        $request->uri,
        $request->content;

    my $response = $self->SUPER::request($request);

    print $fh $response->content;

    return $response;
}

1;
