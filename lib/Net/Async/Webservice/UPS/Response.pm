package Net::Async::Webservice::UPS::Response;
$Net::Async::Webservice::UPS::Response::VERSION = '1.0.7';
{
  $Net::Async::Webservice::UPS::Response::DIST = 'Net-Async-Webservice-UPS';
}
use Moo;
use Types::Standard qw(Str);
use namespace::autoclean;

# ABSTRACT: base class with fields common to all UPS responses


has customer_context => (
    is => 'ro',
    isa => Str,
);

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Net::Async::Webservice::UPS::Response - base class with fields common to all UPS responses

=head1 VERSION

version 1.0.7

=head1 ATTRIBUTES

=head2 C<customer_context>

A string, usually whatever was passed to the request as C<customer_context>.

=head1 AUTHORS

=over 4

=item *

Gianni Ceccarelli <gianni.ceccarelli@net-a-porter.com>

=item *

Sherzod B. Ruzmetov <sherzodr@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gianni Ceccarelli <gianni.ceccarelli@net-a-porter.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
