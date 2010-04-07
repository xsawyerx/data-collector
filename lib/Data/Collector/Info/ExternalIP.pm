package Data::Collector::Info::ExternalIP;

use Carp;
use Moose;
use LWP::UserAgent;
use MooseX::StrictConstructor;
use namespace::autoclean;

extends 'Data::Collector::Info';

has 'url' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'http://checkip.dyndns.org',
);

sub load { Data::Collector::Info->register_keys('external_ip') }

sub _build_raw_data {
    my $self = shift;
    my $url  = $self->url;
    my $data = $self->engine->run("curl $url 2>/dev/null");

    if ( $data =~ /(\d+\.\d+\.\d+\.\d+)/ ) {
        return $1;
    }

    croak q{Coulnd't find IP in output};
}

sub all {
    my $self = shift;
    return {
        external_ip => $self->raw_data,
    };
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::Info::ExternalIP - Fetch machine's external IP information

This info module fetches the external IP of a machine using the DynDNS URL
L<http://checkip.dyndns.org>.

This is good in two situations:

=over 4

=item * When you're trying to determine an external IP inside a network

=item * When you have multiple IPs and want to find the main one

(something that happens quite often on hosting servers)

=back

The key this module takes in the registry is I<external_ip>.

=head1 ATTRIBUTES

=head2 url(Str)

The URL used to fetch the IP. As stated above, it is now
I<http://checkip.dyndns.org>.

=head1 SUBROUTINES/METHODS

=head2 load

Subclassing C<load> from L<Data::Collector::Info> to register keys in the
registry.

=head2 all

Returns a hashref with the key and the request result.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>

