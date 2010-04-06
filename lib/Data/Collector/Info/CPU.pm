package Data::Collector::Info::CPU;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

extends 'Data::Collector::Info';

sub load {
    Data::Collector::Info->register_keys( qw/
        number_of_cpus cpu_mhz cpu_model cpu_flags
    / );
}

sub _build_raw_data {
    my $self   = shift;
    my $engine = $self->engine;

    return $engine->run('cat /proc/cpuinfo');
}

sub all {
    my $self    = shift;
    my %results = (
        number_of_cpus => $self->count,
        cpu_mhz        => $self->mhz,
        cpu_model      => $self->model,
        cpu_flags      => $self->flags,
    );

    return \%results;
}

sub count {
    my $self = shift;
    my @cpus = ( $self->raw_data =~ /^processor\s+\:\s+(.+)\n/gm );
    return scalar @cpus;
}

sub mhz {
    my $self = shift;
    my $data = $self->raw_data;

    return $1 if $data =~ /^cpu MHz\s+\:\s+(.+)\n/m;
}

sub model {
    my $self = shift;
    my $data = $self->raw_data;

    return $1 if $data =~ /^model name\s+\:\s+(.+)\n/m;
}

sub flags {
    my $self = shift;
    my $data = $self->raw_data;

    return $1 if $data =~ /^flags\s+:\s+(.+)\n/m;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::Info::CPU - Fetch machine CPU information

This info module fetches information about a machine's CPU using
C</proc/meminfo>. It will not work on Solaris or Windows.

It would be better to do it using a normalized module. Patches are welcome. :)

The keys this module takes in the registry are I<number_of_cpus>, I<cpu_mhz>,
I<cpu_model> and I<cpu_flags>.

=head1 METHODS/ATTRIBUTES

=head2 load

Subclassing C<load> from L<Data::Collector::Info> to register keys in the
registry.

=head2 count

Returns the number of CPUs.

=head2 mhz

Returns the CPU MHz.

=head2 model

Returns the CPU model.

=head2 flags

Returns the CPU flags.

=head2 all

Runs all methods and returns their result in a unified hashref.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>

