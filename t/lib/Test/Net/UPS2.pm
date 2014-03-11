package Test::Net::UPS2;
use strict;
use warnings;
use Test::Most;
use Data::Printer;
use Net::UPS2::Package;

sub package_comparator {
    my (@p) = @_;

    return map {
        my $p = $_;
        all(
            isa('Net::UPS2::Package'),
            methods(
                map { $_ => $p->$_ } qw(length width height weight packaging_type measurement_system)
            )
        );
    } @p;
}

sub test_it {
    my ($ups) = @_;

    subtest 'setting live / testing' => sub {
        is($ups->live_mode,0,'starts in testing');
        my $test_url = $ups->base_url;

        $ups->live_mode(1);
        is($ups->live_mode,1,'can be set live');
        isnt($ups->base_url,$test_url,'live proxy different than test one');

        $ups->live_mode(0);
        is($ups->live_mode,0,'can be set back to testing');
        is($ups->base_url,$test_url,'test proxy same as before');
    };

    my @postal_codes = ( 15241, 48823 );
    my @addresses = map { Net::UPS2::Address->new(postal_code=>$_) } @postal_codes;
    my @address_comparators = map {
        all(
            isa('Net::UPS2::Address'),
            methods(
                postal_code => $_,
            ),
        ),
    } @postal_codes;

    my @packages = (
        Net::UPS2::Package->new(
            length=>34, width=>24, height=>1.5,
            weight=>1,
            measurement_system => 'english',
        ),
        Net::UPS2::Package->new(
            length=>34, width=>24, height=>1.5,
            weight=>2,
            measurement_system => 'english',
        ),
    );

    my @rate_comparators = map {
        methods(
            warnings => undef,
            services => [
                all(
                    isa('Net::UPS2::Service'),
                    methods(
                        label => 'GROUND',
                        code => '03',
                        rates => [
                            all(
                                isa('Net::UPS2::Rate'),
                                methods(
                                    rated_package => package_comparator($_),
                                    from => $address_comparators[0],
                                    to => $address_comparators[1],
                                    billing_weight => num($_->weight,0.01),
                                ),
                            ),
                        ],
                    ),
                ),
            ],
        ),
    } @packages;

    my $full_rate_comparator = methods(
        warnings => undef,
        services => [
            all(
                isa('Net::UPS2::Service'),
                methods(
                    label => 'GROUND',
                    code => '03',
                    rated_packages => bag(map {package_comparator($_)} @packages),
                    rates => bag(map {
                        all(
                            isa('Net::UPS2::Rate'),
                            methods(
                                rated_package => package_comparator($_),
                                from => $address_comparators[0],
                                to => $address_comparators[1],
                                billing_weight => num($_->weight,0.01),
                            ),
                        ),
                    } @packages),
                ),
            ),
        ],
    );

    my $rate1;
    subtest 'rating a package via postcodes' => sub {
        $rate1 = $ups->request_rate({
            from => $postal_codes[0],
            to => $postal_codes[1],
            packages => $packages[0],
        });
        if ($rate1->isa('Future')) {
            $rate1 = $rate1->get;
        }

        cmp_deeply(
            $rate1,
            $rate_comparators[0],
            'sensible rate returned',
        ) or note p $rate1;
        cmp_deeply(
            $rate1->services->[0]->rated_packages,
            [package_comparator($packages[0])],
            'service refers to the right package'
        );
    };

    subtest 'rating a package via addresss' => sub {
        my $rate2 = $ups->request_rate({
            from => $addresses[0],
            to => $addresses[1],
            packages => $packages[0],
        });
        if ($rate2->isa('Future')) {
            $rate2 = $rate2->get;
        }

        cmp_deeply(
            $rate1,
            $rate_comparators[0],
            'sensible rate returned',
        ) or note p $rate2;
        cmp_deeply(
            $rate2->services->[0]->rated_packages,
            [package_comparator($packages[0])],
            'service refers to the right package'
        );

        cmp_deeply($rate2,$rate1,'same result as with postcodes');
    };

    subtest 'rating multiple packages' => sub {
        my $rate = $ups->request_rate({
            from => $postal_codes[0],
            to => $postal_codes[1],
            packages => \@packages,
        });
        if ($rate->isa('Future')) {
            $rate = $rate->get;
        }

        cmp_deeply(
            $rate,
            $full_rate_comparator,
            'sensible rate returned',
        ) or note p $rate;

        my $service = $rate->services->[0];
        cmp_deeply(
            $service->rated_packages,
            [package_comparator(@packages)],
            'service refers to the both packages'
        );
        my $rates = $rate->services->[0]->rates;
        cmp_deeply(
            $service->total_charges,
            num($rates->[0]->total_charges + $rates->[1]->total_charges,0.01),
            'total charges add up',
        );
    };

    subtest 'shop for rates, single package' => sub {
        my $services = $ups->request_rate({
            from => $addresses[0],
            to => $addresses[1],
            packages => $packages[0],
            mode => 'shop',
        });
        if ($services->isa('Future')) {
            $services = $services->get;
        }

        cmp_deeply(
            $services,
            methods(
                warnings => undef,
                services => all(
                    array_each(all(
                        isa('Net::UPS2::Service'),
                        methods(
                            rated_packages => [package_comparator($packages[0])],
                        ),
                    )),
                    superbagof(all(
                        isa('Net::UPS2::Service'),
                        methods(
                            label => 'GROUND',
                            code => '03',
                        ),
                    )),
                ),
            ),
            'services are returned, including ground',
        );

        my $services_aref = $services->services;
        cmp_deeply(
            $services_aref,
            [ sort { $a->total_charges <=> $b->total_charges } @$services_aref ],
            'sorted by total_charges',
        );
    };

    subtest 'shop for rates, multiple packages' => sub {
        my $services = $ups->request_rate({
            from => $addresses[0],
            to => $addresses[1],
            packages => \@packages,
            mode => 'shop',
        });
        if ($services->isa('Future')) {
            $services = $services->get;
        }

        cmp_deeply(
            $services,
            methods(
                warnings => undef,
                services => all(
                    array_each(all(
                        isa('Net::UPS2::Service'),
                        methods(
                            rated_packages => [package_comparator(@packages)],
                            rates => bag(
                                map {
                                    all(
                                        isa('Net::UPS2::Rate'),
                                        methods(
                                            rated_package => package_comparator($_),
                                            from => $address_comparators[0],
                                            to => $address_comparators[1],
                                        ),
                                    ),
                                } @packages,
                            ),
                        ),
                    )),
                    superbagof(all(
                        isa('Net::UPS2::Service'),
                        methods(
                            label => 'GROUND',
                            code => '03',
                        ),
                    )),
                ),
            ),
            'services are returned, including ground, with multiple rates each',
        ) or note p $services;

        my $services_aref = $services->services;
        cmp_deeply(
            $services_aref,
            [ sort { $a->total_charges <=> $b->total_charges } @$services_aref ],
            'sorted by total_charges',
        );

        for my $service (@$services_aref) {
            my $rates = $service->rates;
            cmp_deeply(
                $service->total_charges,
                num($rates->[0]->total_charges + $rates->[1]->total_charges,0.01),
                'total charges add up',
            );
        }
        ;
    };

    subtest 'validate address' => sub {
        my $address = Net::UPS2::Address->new({
            city        => "East Lansing",
            state       => "MI",
            country_code=> "US",
            postal_code => "48823",
            is_residential=>1
        });

        my $addresses = $ups->validate_address($address, 0);
        if ($addresses->isa('Future')) {
            $addresses = $addresses->get;
        }

        cmp_deeply(
            $addresses,
            methods(
                warnings => undef,
                addresses => array_each(
                    all(
                        isa('Net::UPS2::Address'),
                        methods(
                            city => "EAST LANSING",
                            state => "MI",
                            country_code=> "US",
                            quality => num(1,0.01),
                        ),
                    ),
                ),
            ),
            'sensible addresses returned',
        ) or note p $addresses;
    };
}

1;
