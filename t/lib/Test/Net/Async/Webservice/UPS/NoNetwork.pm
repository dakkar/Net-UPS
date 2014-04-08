package Test::Net::Async::Webservice::UPS::NoNetwork;
use strict;
use warnings;
use Moo;
use Future;
extends 'Test::Net::UPS::NoNetwork';

sub do_request {
    my ($self,%args) = @_;

    return Future->wrap($self->request($args{request}));
}

sub POST {}

1;
