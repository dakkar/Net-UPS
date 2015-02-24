#!perl
use strict;
use warnings;
use Test::Most;
use Encode;
use XML::Simple;
use XML::SAX;
use Devel::Peek;

my $string = "Snowman \x{2603}";
my $xml = encode 'UTF-8',"<str>$string</str>";

my @parsers = ('XML::Parser', map {$_->{Name}} @{XML::SAX->parsers});

for my $parser (@parsers) {
    subtest $parser => sub {
        $XML::Simple::PREFERRED_PARSER=$parser;
        my $data;
        my $worked = eval { $data = XMLin($xml); 1 };
        if ($worked) {
            my $version = $parser->VERSION;
            is($data,$string,"$parser ($version) handles Unicode correctly");
        }
        else {
            my $exception = $@;
            fail("$parser couldn't be used: $exception");
        }
    };
}

done_testing();
