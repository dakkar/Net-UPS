package Test::Net::Async::Webservice::UPS::NoNetwork;
use strict;
use warnings;
use Moo;
use Future;
extends 'Test::Net::UPS2::NoNetwork';

sub do_request {
    my ($self,%args) = @_;

    my $res = $self->request($args{request});
    if ($res->is_success) {
        return Future->wrap($res);
    }
    else {
        return Future->new->fail(
            $res->status_line,
            'http',
            $res,
            $args{request},
        );
    }
}

sub POST {}

1;
