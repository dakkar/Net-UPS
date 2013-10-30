package Test::Net::UPS::NoNetwork;
use strict;
use warnings;
use Net::UPS;
use XML::Simple;
use HTTP::Response;

our @ISA=('Net::UPS');

our @requests;our @responses;

# we don't need this in tests, and it makes parsing the requsets
# harder
sub access_as_xml { '' }

sub post {
    my ($self,$url,$content) = @_;

    my $parsed_content = XMLin(
        $content,
        KeepRoot=>1,
        NoAttr=>1, KeyAttr=>[],
    );

    push @requests,[$url,$parsed_content];

    if (@responses) {
        my ($status,$data) = @{shift @responses};
        return HTTP::Response->new(
            $status,
            'test response',
            [], # headers
            XMLout(
                $data,
                KeepRoot => 0,
                NoAttr => 1,
                KeyAttr => [],
                ForceArray => [
                    'RatedPackage', 'RatedShipment',
                    'AddressValidationResult',
                ],
            ),
        );
    }
    else {
        return HTTP::Response->new(
            500,
            'no test response prepared',
            [],
            '',
        );
    }
}

sub pop_last_request {
    return @{pop @requests};
}

sub push_test_response {
    push @responses,[@_];
}

1;
