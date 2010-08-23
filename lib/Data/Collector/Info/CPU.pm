use strictures 1;
package Data::Collector::Info::CPU;
# ABSTRACT: Fetch machine CPU information

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

extends 'Data::Collector::Info';
with    'Data::Collector::Commands';

sub info_keys { [qw/number_of_cpus cpu_mhz cpu_model cpu_flags/] }

sub _build_raw_data {
    my $self = shift;
    my $cat  = $self->get_command('cat');
    return $self->engine->run("$cat /proc/cpuinfo");
}

sub all {
    my $self = shift;
    return {
        number_of_cpus => $self->count,
        cpu_mhz        => $self->mhz,
        cpu_model      => $self->model,
        cpu_flags      => $self->flags,
    };
}

sub count {
    my $self = shift;
    my @cpus = ( $self->raw_data =~ /^processor\s+\:\s+(.+)\n/gm );
    return scalar @cpus;
}

sub mhz {
    my $self = shift;
    my $raw  = $self->raw_data || q{};
    return $1 if $raw =~ /^cpu MHz\s+\:\s+(.+)\n/m;
}

sub model {
    my $self = shift;
    my $raw  = $self->raw_data || q{};
    return $1 if $raw =~ /^model name\s+\:\s+(.+)\n/m;
}

sub flags {
    my $self = shift;
    my $raw  = $self->raw_data || q{};
    return $1 if $raw =~ /^flags\s+:\s+(.+)\n/m;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 DESCRIPTION

This info module fetches information about a machine's CPU using
C</proc/meminfo>. It will not work on Solaris or Windows.

It would be better to do it using a normalized module. Patches are welcome. :)

The keys this module takes in the registry are I<number_of_cpus>, I<cpu_mhz>,
I<cpu_model> and I<cpu_flags>.

=head1 SUBROUTINES/METHODS

=head2 info_keys

Subclassing C<info_keys> from L<Data::Collector::Info> to indicate which keys
to register.

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

