package Net::Async::Webservice::UPS;
use strict;
use warnings;
use Moo;
use XML::Simple;
use Types::Standard qw(Str Bool Object Dict Optional ArrayRef HashRef Undef);
use Type::Params qw(compile);
use Error::TypeTiny;
use Net::Async::Webservice::UPS::Types qw(:types to_Service);
use Net::Async::Webservice::UPS::Exception;
use Try::Tiny;
use List::AllUtils 'pairwise';
use HTTP::Request;
use Encode;
use namespace::autoclean;
use Net::Async::Webservice::UPS::Rate;
use Net::Async::Webservice::UPS::Address;
use Net::Async::Webservice::UPS::Service;
use Net::Async::Webservice::UPS::Response::Rate;
use Net::Async::Webservice::UPS::Response::Address;
use Future;
use 5.10.0;

# ABSTRACT: UPS API client, non-blocking

=head1 SYNOPSIS

 use IO::Async::Loop;
 use Net::Async::Webservice::UPS;

 my $loop = IO::Async::Loop->new;

 my $ups = Net::Async::Webservice::UPS->new({
   config_file => $ENV{HOME}.'/.upsrc.conf',
   loop => $loop,
 });

 $ups->validate_address($postcode)->then(sub {
   my ($response) = @_;
   say $_->postal_code for @{$response->addresses};
   return Future->wrap();
 });

 $loop->run;

=head1 DESCRIPTION

This class implements some of the methods of the UPS API, using
L<Net::Async::HTTP> as a user agent. All methods that perform API
calls return L<Future>s.

=cut

my %code_for_pickup_type = (
    DAILY_PICKUP            => '01',
    DAILY                   => '01',
    CUSTOMER_COUNTER        => '03',
    ONE_TIME_PICKUP         => '06',
    ONE_TIME                => '06',
    ON_CALL_AIR             => '07',
    SUGGESTED_RETAIL        => '11',
    SUGGESTED_RETAIL_RATES  => '11',
    LETTER_CENTER           => '19',
    AIR_SERVICE_CENTER      => '20'
);

my %code_for_customer_classification = (
    WHOLESALE               => '01',
    OCCASIONAL              => '03',
    RETAIL                  => '04'
);

my %base_urls = (
    live => 'https://onlinetools.ups.com/ups.app/xml',
    test => 'https://wwwcie.ups.com/ups.app/xml',
);

=attr C<live_mode>

Boolean, defaults to false. When set to true, the live API endpoint
will be used, otherwise the test one will. Flipping this attribute
will reset L</base_url>, so you generally don't want to touch this if
you're using some custom API endpoint.

=cut

has live_mode => (
    is => 'rw',
    isa => Bool,
    trigger => 1,
    default => sub { 0 },
);

=attr C<base_url>

A string. The base URL to use to send API requests to (actual requests
will be C<POST>ed to an actual URL build from this by appending the
appropriate service path). Defaults to the standard UPS endpoints:

=for :list
* C<https://onlinetools.ups.com/ups.app/xml> for live
* C<https://wwwcie.ups.com/ups.app/xml> for testing

See also L</live_mode>.

=cut

has base_url => (
    is => 'lazy',
    isa => Str,
    clearer => '_clear_base_url',
);

sub _trigger_live_mode {
    my ($self) = @_;

    $self->_clear_base_url;
}
sub _build_base_url {
    my ($self) = @_;

    return $base_urls{$self->live_mode ? 'live' : 'test'};
}

=attr C<user_id>

=attr C<password>

=attr C<access_key>

Strings, required. Authentication credentials.

=cut

has user_id => (
    is => 'ro',
    isa => Str,
    required => 1,
);
has password => (
    is => 'ro',
    isa => Str,
    required => 1,
);
has access_key => (
    is => 'ro',
    isa => Str,
    required => 1,
);

=attr C<account_number>

String. Used in some requests as "shipper number".

=cut

has account_number => (
    is => 'ro',
    isa => Str,
);

=attr C<customer_classification>

String, usually one of C<WHOLESALE>, C<OCCASIONAL>, C<RETAIL>. Used
when requesting rates.

=cut

has customer_classification => (
    is => 'rw',
    isa => CustomerClassification,
);

=attr C<pickup_type>

String, defaults to C<ONE_TIME>. Used when requesting rates.

=cut

has pickup_type => (
    is => 'rw',
    isa => PickupType,
    default => sub { 'ONE_TIME' },
);

=attr C<cache>

Responses are cached if this is set. You can pass your own cache
object (that implements the C<get> and C<set> methods like L<CHI>
does), or use the C<cache_life> and C<cache_root> constructor
parameters to get a L<CHI> instance based on L<CHI::Driver::File>.

=cut

has cache => (
    is => 'ro',
    isa => Cache|Undef,
);

=method C<does_caching>

Returns a true value if caching is enabled.

=cut

sub does_caching {
    my ($self) = @_;
    return defined $self->cache;
}

=attr C<user_agent>

A user agent object implementing C<do_request> and C<POST> like
L<Net::Async::HTTP>. You can pass the C<loop> constructor parameter
to get a default user agent.

=cut

has user_agent => (
    is => 'ro',
    isa => AsyncUserAgent,
    required => 1,
);

=method C<new>

  my $ups = Net::Async::Webservice::UPS->new({
     loop => $loop,
     config_file => $file_name,
     cache_life => 5,
  });

In addition to passing all the various attributes values, you can use
a few shortcuts.

=for :list
= C<loop>
a L<IO::Async::Loop>; a locally-constructer L</user_agent> will be registered to it
= C<config_file>
a path name; will be parsed with L<Config::Any>, and the values used as if they had been passed in to the constructor
= C<cache_life>
lifetime, in minutes, of cache entries; a L</cache> will be built automatically if this is set
= C<cache_root>
where to store the cache files, defaults to a temporary directory

=cut

around BUILDARGS => sub {
    my ($orig,$class,@args) = @_;

    my $ret = $class->$orig(@args);

    if (my $config_file = delete $ret->{config_file}) {
        $ret = {
            %{_load_config_file($config_file)},
            %$ret,
        };
    }

    if (ref $ret->{loop} && !$ret->{user_agent}) {
        require Net::Async::HTTP;
        $ret->{user_agent} = Net::Async::HTTP->new();
        $ret->{loop}->add($ret->{user_agent});
    }

    if ($ret->{cache_life}) {
        require CHI;
        if (not $ret->{cache_root}) {
            require File::Spec;
            $ret->{cache_root} =
                File::Spec->catdir(File::Spec->tmpdir,'net_ups2'),
              }
        $ret->{cache} = CHI->new(
            driver => 'File',
            root_dir => $ret->{cache_root},
            depth => 5,
            expires_in => $ret->{cache_life} . ' min',
        );
    }

    return $ret;
};

sub _load_config_file {
    my ($file) = @_;
    require Config::Any;
    my $loaded = Config::Any->load_files({
        files => [$file],
        use_ext => 1,
        flatten_to_hash => 1,
    });
    my $config = $loaded->{$file};
    Net::Async::Webservice::UPS::Exception::ConfigError->throw({
        file => $file,
    }) unless $config;
    return $config;
}

=method C<transaction_reference>

Constant data used to fill something in requests. I don't know what
it's for.

=cut

sub transaction_reference {
    return {
        CustomerContext => "Net::UPS",
        XpciVersion     => '1.0001'
    };
}

=method C<access_as_xml>

Returns a XML document with the credentials.

=cut

sub access_as_xml {
    my $self = shift;
    return XMLout({
        AccessRequest => {
            AccessLicenseNumber  => $self->access_key,
            Password            => $self->password,
            UserId              => $self->user_id,
        }
    }, NoAttr=>1, KeepRoot=>1, XMLDecl=>1);
}

=method C<request_rate>

  $ups->request_rate({
    from => $address_a,
    to => $address_b,
    packages => [ $package_1, $package_2 ],
  }) ==> (Net::Async::Webservice::UPS::Response::Rate)

C<from> and C<to> are instances of
L<Net::Async::Webservice::UPS::Address>, or postcode strings that will
be coerced to addresses.

C<packages> is an arrayref of L<Net::Async::Webservice::UPS::Package>
(or a single package, will be coerced to a 1-element array ref).

Optional parameters:

=for :list
= C<limit_to>
only accept some services (see L<Net::Async::Webservice::UPS::Types/ServiceLabel>)
= C<exclude>
exclude some services (see L<Net::Async::Webservice::UPS::Types/ServiceLabel>)
= C<mode>
defaults to C<rate>, could be C<shop>
= C<service>
defaults to C<GROUND>, see L<Net::Async::Webservice::UPS::Service>

The L<Future> returned will yield an instance of
L<Net::Async::Webservice::UPS::Response::Rate>, or fail with an
exception.

=cut

sub request_rate {
    state $argcheck = compile(Object, Dict[
        from => Address,
        to => Address,
        packages => PackageList,
        limit_to => Optional[ArrayRef[Str]],
        exclude => Optional[ArrayRef[Str]],
        mode => Optional[RequestMode],
        service => Optional[Service],
    ]);
    my ($self,$args) = $argcheck->(@_);
    $args->{mode} ||= 'rate';
    $args->{service} ||= to_Service('GROUND');

    if ( $args->{exclude} && $args->{limit_to} ) {
        Error::TypeTiny::croak("You cannot use both 'limit_to' and 'exclude' at the same time");
    }

    my $packages = $args->{packages};

    unless (scalar(@$packages)) {
        Error::TypeTiny::croak("request_rate() was given an empty list of packages");
    }

    { my $pack_id=0; $_->id(++$pack_id) for @$packages }

    my $cache_key;
    if ($self->does_caching) {
        $cache_key = $self->generate_cache_key(
            'rate',
            [ $args->{from},$args->{to},@$packages, ],
            {
                mode => $args->{mode},
                service => $args->{service}->code,
                pickup_type => $self->pickup_type,
                customer_classification => $self->customer_classification,
            },
        );
        if (my $cached_services = $self->cache->get($cache_key)) {
            return Future->wrap($cached_services);
        }
    }

    my %request = (
        RatingServiceSelectionRequest => {
            Request => {
                RequestAction   => 'Rate',
                RequestOption   =>  $args->{mode},
                TransactionReference => $self->transaction_reference,
            },
            PickupType  => {
                Code    => $code_for_pickup_type{$self->pickup_type},
            },
            Shipment    => {
                Service     => { Code   => $args->{service}->code },
                Package     => [map { $_->as_hash() } @$packages],
                Shipper     => {
                    %{$args->{from}->as_hash()},
                    ( $self->account_number ?
                        ( ShipperNumber => $self->account_number )
                      : () ),
                },
                ShipTo      => $args->{to}->as_hash(),
            },
            ( $self->customer_classification ? (
                CustomerClassification => { Code => $code_for_customer_classification{$self->customer_classification} }
            ) : () ),
        }
    );

    # default to "all allowed"
    my %ok_labels = map { $_ => 1 } @{ServiceLabel->values};
    if ($args->{limit_to}) {
        # deny all, allow requested
        %ok_labels = map { $_ => 0 } @{ServiceLabel->values};
        $ok_labels{$_} = 1 for @{$args->{limit_to}};
    }
    elsif ($args->{exclude}) {
        # deny requested
        $ok_labels{$_} = 0 for @{$args->{exclude}};
    }

    $self->xml_request({
        data => \%request,
        url_suffix => '/Rate',
        XMLin => {
            ForceArray => [ 'RatedPackage', 'RatedShipment' ],
        },
    })->transform(
        done => sub {
            my ($response) = @_;

            my @services;
            for my $rated_shipment (@{$response->{RatedShipment}}) {
                my $code = $rated_shipment->{Service}{Code};
                my $label = Net::Async::Webservice::UPS::Service::label_for_code($code);
                next if not $ok_labels{$label};

                push @services, my $service = Net::Async::Webservice::UPS::Service->new({
                    code => $code,
                    label => $label,
                    total_charges => $rated_shipment->{TotalCharges}{MonetaryValue},
                    # TODO check this logic
                    ( ref($rated_shipment->{GuaranteedDaysToDelivery})
                          ? ()
                          : ( guaranteed_days => $rated_shipment->{GuaranteedDaysToDelivery} ) ),
                    rated_packages => $packages,
                    # TODO check this pairwise
                    rates => [ pairwise {
                        Net::Async::Webservice::UPS::Rate->new({
                            billing_weight  => $a->{BillingWeight}{Weight},
                            unit            => $a->{BillingWeight}{UnitOfMeasurement}{Code},
                            total_charges   => $a->{TotalCharges}{MonetaryValue},
                            total_charges_currency => $a->{TotalCharges}{CurrencyCode},
                            weight          => $a->{Weight},
                            rated_package   => $b,
                            from            => $args->{from},
                            to              => $args->{to},
                        });
                    } @{$rated_shipment->{RatedPackage}},@$packages ],
                });

                # fixup service-rate-service refs
                $_->_set_service($service) for @{$service->rates};
            }
            @services = sort { $a->total_charges <=> $b->total_charges } @services;

            my $ret = Net::Async::Webservice::UPS::Response::Rate->new({
                services => \@services,
                ( $response->{Error} ? (warnings => $response->{Error}) : () ),
            });

            $self->cache->set($cache_key,$ret) if $self->does_caching;

            return $ret;
        },
    );
}

=method C<validate_address>

  $ups->validate_address($address)
    ==> (Net::Async::Webservice::UPS::Response::Address)

C<$address> is an instance of L<Net::Async::Webservice::UPS::Address>,
or a postcode string that will be coerced to an address.

Optional parameter: a tolerance (float, between 0 and 1). Returned
addresses with quality below the tolerance will be filtered out.

The L<Future> returned will yield an instance of
L<Net::Async::Webservice::UPS::Response::Address>, or fail with an
exception.

=cut

sub validate_address {
    state $argcheck = compile(
        Object,
        Address, Optional[Tolerance],
    );
    my ($self,$address,$tolerance) = $argcheck->(@_);

    $tolerance //= 0.05;

    my %data = (
        AddressValidationRequest => {
            Request => {
                RequestAction => "AV",
                TransactionReference => $self->transaction_reference(),
            },
            Address => {
                ( $address->city ? ( City => $address->city ) : () ),
                ( $address->state ? ( StateProvinceCode => $address->state) : () ),
                ( $address->postal_code ? ( PostalCode => $address->postal_code) : () ),
            },
        },
    );

    my $cache_key;
    if ($self->does_caching) {
        $cache_key = $self->generate_cache_key(
            'AV',
            [ $address ],
            { tolerance => $tolerance },
        );
        if (my $cached_services = $self->cache->get($cache_key)) {
            return Future->wrap($cached_services);
        }
    }

    $self->xml_request({
        data => \%data,
        url_suffix => '/AV',
        XMLin => {
            ForceArray => [ 'AddressValidationResult' ],
        },
    })->transform(
        done => sub {
            my ($response) = @_;

            my @addresses;
            for my $address (@{$response->{AddressValidationResult}}) {
                next if $address->{Quality} < (1 - $tolerance);
                for my $possible_postal_code ($address->{PostalCodeLowEnd} .. $address->{PostalCodeHighEnd}) {
                    push @addresses, Net::Async::Webservice::UPS::Address->new({
                        quality         => $address->{Quality},
                        postal_code     => $possible_postal_code,
                        city            => $address->{Address}->{City},
                        state           => $address->{Address}->{StateProvinceCode},
                        country_code    => "US",
                    });
                }
            }


            my $ret = Net::Async::Webservice::UPS::Response::Address->new({
                addresses => \@addresses,
                ( $response->{Error} ? (warnings => $response->{Error}) : () ),
            });

            $self->cache->set($cache_key,$ret) if $self->does_caching;
            return $ret;
        },
    );
}

sub xml_request {
    state $argcheck = compile(
        Object,
        Dict[
            data => HashRef,
            url_suffix => Str,
            XMLout => Optional[HashRef],
            XMLin => Optional[HashRef],
        ],
    );
    my ($self, $args) = $argcheck->(@_);

    # default XML::Simple args
    my $xmlargs = {
        NoAttr     => 1,
        KeyAttr    => [],
    };

    my $request =
        $self->access_as_xml .
            XMLout(
                $args->{data},
                %{ $xmlargs },
                XMLDecl     => 1,
                KeepRoot    => 1,
                %{ $args->{XMLout}||{} },
            );

    return $self->post( $args->{url_suffix}, $request )->then(
        sub {
            my ($response_string) = @_;

            my $response = XMLin(
                $response_string,
                %{ $xmlargs },
                %{ $args->{XMLin} },
            );

            if ($response->{Response}{ResponseStatusCode}==0) {
                return Future->new->fail(
                    Net::Async::Webservice::UPS::Exception::UPSError->new({
                        error => $response->{Response}{Error}
                    })
                  );
            }
            return Future->wrap($response);
        },
    );
}

sub post {
    state $argcheck = compile( Object, Str, Str );
    my ($self, $url_suffix, $body) = $argcheck->(@_);

    my $url = $self->base_url . $url_suffix;
    my $request = HTTP::Request->new(
        POST => $url,
        [], encode('utf-8',$body),
    );
    my $response_future = $self->user_agent->do_request(
        request => $request,
        fail_on_error => 1,
    )->transform(
        done => sub {
            my ($response) = @_;
            return $response->decoded_content(
                default_charset => 'utf-8',
                raise_error => 1,
            )
        },
        fail => sub {
            my ($exception,undef,$response,$request) = @_;
            return Net::Async::Webservice::UPS::Exception::HTTPError->new({
                request=>$request,
                response=>$response,
            })
        },
    );
}

sub generate_cache_key {
    state $argcheck = compile(Object, Str, ArrayRef[Cacheable],Optional[HashRef]);
    my ($self,$kind,$things,$args) = $argcheck->(@_);

    return join ':',
        $kind,
        ( map { $_->cache_id } @$things ),
        ( map {
            sprintf '%s:%s',
                $_,
                ( defined($args->{$_}) ? '"'.$args->{$_}.'"' : 'undef' )
            } sort keys %{$args || {}}
        );
}

1;
