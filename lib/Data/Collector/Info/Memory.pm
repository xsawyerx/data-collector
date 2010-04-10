package Data::Collector::Info::Memory;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

extends 'Data::Collector::Info';
with    'Data::Collector::Commands';

sub load {
    Data::Collector::Info->register( qw/ total_memory free_memory / );
}

sub _build_raw_data {
    my $self = shift;
    my $cat  = $self->get_command('cat');
    return $self->engine->run("$cat /proc/meminfo");
}

sub all {
    my $self = shift;
    return {
        total_memory => $self->total,
        free_memory  => $self->free,
    };
}

sub total {
    my $self = shift;
    return $1 if $self->raw_data =~ /MemTotal\:\s+(\d+)\skB/;
}

sub free {
    my $self = shift;
    return $1 if $self->raw_data =~ /MemFree\:\s+(\d+)\skB/;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::Info::Memory - Fetch machine RAM information

This info module fetches information about a machine's RAM status using
C</proc/meminfo>. It will not work on Solaris or Windows.

It would be better to do it using a normalized module. Patches are welcome. :)

The keys this module takes in the registry are I<free_memory> and
I<total_memory>.

=head1 SUBROUTINES/METHODS

=head2 load

Subclassing C<load> from L<Data::Collector::Info> to register keys in the
registry.

=head2 total

Returns the total memory.

=head2 free

Returns the free memory.

=head2 all

Runs both methods and returns their result in a unified hashref.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>

