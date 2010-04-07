package Data::Collector::Info::IFaces;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

extends 'Data::Collector::Info';
with    'Data::Collector::Commands';

has 'ignore_ip'    => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has 'ignore_iface' => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

sub load { Data::Collector::Info->register_keys('ifaces') }

sub _build_raw_data {
    my $self = shift;
    return $self->engine->run( $self->get_command('ifconfig') );
}

sub all {
    my $self = shift;
    return { ifaces => $self->ifaces };
}

sub ifaces {
    my $self          = shift;
    my @data          = split /\n/, $self->raw_data;
    my $ignores       = $self->ignore_ip;
    my %ifaces        = ();
    my $current_iface = q{};

    chomp @data;

IFACE:
    foreach my $line (@data) {
        if ( $line =~ /^ (.+) \s+ Link/x ) {
            $current_iface = $1;
        }

        # doesn't make sense
        $current_iface =~ s/\s+$//;

        if ( $line =~ / addr \: (\d+\.\d+\.\d+\.\d+) /x ) {
            my $ip = $1;

            foreach my $ignore_ip ( @{$ignores} ) {
                if ( $ip eq $ignore_ip ) {
                    next IFACE;
                }
            }

            $ifaces{$current_iface} = $ip;
        }
    }

    return \%ifaces
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::Info::IFaces - Fetch machine interfaces information

This info module fetches information about a machine's internet interfaces using
C<ifconfig>. This should not work on Windows.

The key this module takes in the registry is I<ifaces>.

=head1 ATTRIBUTES

=head2 ignore

A list of interfaces to ignore.

=head1 SUBROUTINES/METHODS

=head2 load

Subclassing C<load> from L<Data::Collector::Info> to register keys in the
registry.

=head2 ifaces

Returns the interfaces and their IPs.

=head2 all

Runs C<ifaces> method and returns their result in a unified hashref.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>

