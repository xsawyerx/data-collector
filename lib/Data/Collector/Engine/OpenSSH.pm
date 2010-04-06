package Data::Collector::Engine::OpenSSH;

use Moose;
use Net::OpenSSH;
use MooseX::StrictConstructor;
use namespace::autoclean;

our $VERSION = '0.01';

extends 'Data::Collector::Engine';

has '+name'  => ( default => 'OpenSSH' );

has 'host'   => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_host',
    required  => 1,
);

has 'user'   => ( is => 'rw', isa => 'Str', predicate => 'has_user'   );
has 'passwd' => ( is => 'rw', isa => 'Str', predicate => 'has_passwd' );
has 'ssh'    => ( is => 'rw', isa => 'Net::OpenSSH' );

sub connect {
    my $self = shift;
    my %data = ();

    foreach my $attr ( qw/ user passwd / ) {
        my $predicate = "has_$attr";
        $self->$predicate and $data{$attr} = $self->$attr;
    }

    my $ssh = Net::OpenSSH->new( $self->host, %data );

    $ssh->error and die "OpenSSH Engine connect failed: " . $ssh->error;
    $self->ssh($ssh);
}

sub run {
    my ( $self, $cmd ) = @_;

    return $self->ssh->capture($cmd);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::Engine::OpenSSH - An OpenSSH engine for Data::Collector
utilizing Net::OpenSSH

=head1 SYNOPSIS

    use Data::Collector;

    my $collector = Data::Collector->new(
        engine      => 'OpenSSH', # the default
        engine_args => {
            user   => 'me',
            host   => 'soymilkyway',
            passwd => 'crow@MIDn1ght',
        },
    );

=head1 ATTRIBUTES

=head2 host(Str)

Host to connect to. B<Required>.

=head2 user(Str)

Username to connect with. Defaults to session user.

=head2 passwd(Str)

Password to be used in connection. As with the OpenSSH C<ssh> program, if a
password is ot provided, it will go over other methods (such as keys), so this
is not required.

=head2 ssh(Object)

Contains the L<Net::OpenSSH> object that is used.

=head1 SUBROUTINES/METHODS

=head2 connect

This method creates the Net::OpenSSH object and connects to the host.

=head2 run

This functions runs the given command on the host using ssh and returns the
results.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>

