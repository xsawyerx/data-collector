package Data::Collector::Engine::Local;

use Moose;
use IPC::System::Simple 'capture';
use MooseX::StrictConstructor;
use namespace::autoclean;

extends 'Data::Collector::Engine';

has '+name'  => ( default => 'Local' );

sub run {
    my ( $self, $cmd ) = @_;

    return capture($cmd);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::Engine::Local - An engine for Data::Collector that runs local
commands

=head1 SYNOPSIS

    use Data::Collector;

    my $collector = Data::Collector->new(
        engine => 'Local',
    );

This engine helps debugging Data::Collector better by running commands locally.

=head2 run

This functions runs the given command locally using IPC::System::Simple.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>

