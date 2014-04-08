package Test::Net::UPS2::NoNetwork;
use strict;
use warnings;
use Moo;
use XML::Simple;
use HTTP::Response;
use Test::Deep;

our @requests;our @testing_requests;our @responses;

sub request {
    my ($self,$request) = @_;

    my $url = $request->uri;
    my $content = $request->content;

    # remove the access request prefixed document
    $content =~ s{\A <\?xml .*? (?= <\?xml)}{}xms;

    my $parsed_content = XMLin(
        $content,
        KeepRoot=>1,
        NoAttr=>1, KeyAttr=>[],
    );

    push @requests,[$url,$parsed_content];
    if (@testing_requests) {
        my ($url,$request_comp,$comment) = @{shift @testing_requests};
        cmp_deeply([$url,$parsed_content],
                   [$url,$request_comp],
                   $comment || 'expected request');
    }

    if (@responses) {
        my $data = shift @responses;
        return HTTP::Response->new(
            200,'OK',[],
            (ref($data) ? ( XMLout(
                $data,
                KeepRoot => 1,
                NoAttr => 1,
                KeyAttr => [],
                XMLDecl => 1,
            ) ) : $data),
        );
    }
    else {
        return HTTP::Response->new(
            500,'no test response prepared',
            [],'',
        );
    }
}

sub prepare_test_from_file {
    my ($self,$file,$comment) = @_;

    my ($req_line,$request,$response) = do {
        open my $fh,'<',$file;
        local $/="";
        <$fh>;
    };
    $req_line =~ s{^POST }{}; # remove HTTP verb, we know it's a POST
    $request = XMLin(
        $request,
        KeepRoot=>1,
        NoAttr=>1, KeyAttr=>[],
    );
    push @testing_requests,[$req_line,$request];
    push @responses,$response;
    return;
}

sub pop_last_request {
    return @{pop @requests};
}

sub push_test_responses {
    shift;
    push @responses,@_;
}

sub post {}

1;
