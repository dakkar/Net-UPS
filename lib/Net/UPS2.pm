{package Net::UPS2;
use strict;
use warnings;
use Moo;
use Net::Async::UPS;
use 5.10.0;

# ABSTRACT: attempt to re-implement Net::UPS with modern insides

my @delegate_simple_methods=qw(
   live_mode
   base_url_test
   base_url_live
   base_url
   user_agent
   user_id
   password
   access_key
   account_number
   customer_classification
   pickup_type
   cache
   does_caching
   transaction_reference
   access_as_xml
);
my @delegate_future_methods=qw(
   request_rate
   validate_address
   xml_request
   post
);

has _engine => (
    is => 'ro',
    init_arg => '_engine',
    handles => [@delegate_simple_methods,@delegate_future_methods],
);

for my $m (@delegate_future_methods) {
    around $m => sub {
        my ($orig,$self,@etc) = @_;
        return $self->_engine->$m(@etc)->get;
    };
}

sub BUILDARGS {
    my ($class,@args) = @_;

    my %engine_args;
    if (@args==1 and not ref($args[0])) {
        %engine_args = ( config_file => $args[0] );
    }
    elsif (@args==1 and ref($args[0]) eq 'HASH') {
        %engine_args = %{$args[0]};
    }
    else {
        %engine_args = @args;
    }
    $engine_args{user_agent} = Net::UPS2::FutureUA->new(
        ($engine_args{user_agent} ?
             ( ua => $engine_args{user_agent})
           : () ),
    );

    my %args;
    $args{_engine} = Net::Async::UPS->new(\%engine_args);

    return \%args;
}
}

{package
  Net::UPS2::FutureUA;
use strict;
use warnings;
use Moo;
use Net::UPS2::Types qw(:types);

has ua => (
    is => 'lazy',
    isa => UserAgent,
);
sub _build_ua {
    require LWP::UserAgent;
    return LWP::UserAgent->new(
        env_proxy => 1,
    );
}

sub do_request {
    my ($self,%args) = @_;

    return Future->wrap($self->ua->request($args{request}));
}

sub POST {}

}

1;
