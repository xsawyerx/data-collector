package Data::Collector::Engine;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

has 'name'      => ( is => 'ro', isa => 'Str' );
has 'connected' => (
    is        => 'rw',
    isa       => 'Bool',
    default   => 0,
);

# basic overridable methods
sub run        { die 'No default run method' }
sub connect    {1}
sub disconnect {1}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::Engine - A base class for collecting engines

=head1 SYNOPSIS

This synopsis shows how to write an (almost) full-fledged Telnet engine for
L<Data::Collector>.

    package Data::Collector::Engine::Telnet;

    use Moose;
    use Net::Telnet;
    use namespace::autoclean; # general recommendation
    extends 'Data::Collector::Engine';

    has 'host'   => ( is => 'ro', isa => 'Str',         required   => 1 );
    has 'telnet' => ( is => 'ro', isa => 'Net::Telnet', lazy_build => 1 );

    has '+name'  => ( default => 'Telnet' );

    sub _build_telnet {
        my $self   = shift;
        my $telnet = Net::Telnet->new();
    }

    sub connect {
        my $self = shift;
        $self->telnet->open( $self->host );
        $self->telnet->login(...);
    }

    sub run {
        my ( $self, $command ) = @_;
        my $telnet = $self->telnet;
        my @lines  = $telnet->cmd($command);
        ...
    }

    sub disconnect { ... }

While we all hate long synopsises, this is the best way to demonstrate how
L<Data::Collector::Engine> works. You'll see we made a new engine that inherits
from this base class. We create a I<connect>, I<run> and I<disconnect>.

=head1 ATTRIBUTES

=head2 name(Str)

This has no default, but should be set. It is currently not used, but it might
in the future. It's important that every engine has its own name.

With L<Moose> goodness you can just change the value this way:

    has '+name' => ( default => 'MyEngine' );

=head2 connected(Bool)

A boolean to declare whether the engine is connected or not. This is in place
because engine are most likely to be connection-based (network, DB, etc.). The
I<connect> or I<disconnect> method calling is dependent on this boolean.

=head1 SUBROUTINES/METHODS

=head2 connect

This method gets called before the I<run> method, to allow your engine to
connect to wherever it needs.

This is also called in a lazy context, which means it will not be called on
load but as close as possible to whenever the engine is needed.

At this point you would probably want to set the I<connected> boolean attribute
on. Read more below under I<disconnect>.

=head2 run

This is the main method of the engine. The arguments are populated by the info
component. It may be a command to run, it may be something else. While there
should be an API of argument types and indicating support for them, there isn't
one at the moment. This should change.

If you do not provide a run method, your engine will die, literally! :)

=head2 disconnect

A I<disconnect> is attempted if the I<connected> boolean is set.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>
