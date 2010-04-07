package Data::Collector::Commands;

use Moose::Role;
use namespace::autoclean;

has 'commands' => (
    is      => 'rw',
    isa     => 'HashRef[Str]',
    traits  => ['Hash'],
    default => sub { {
        cat  => '/bin/cat',
        test => '/usr/bin/test',
        echo => '/bin/echo',
        curl => '/usr/bin/curl',
    } },
    handles => {
        set_command => 'set',
        get_command => 'get',
    },
);

1;

__END__

=head1 NAME

Data::Collector::Commands - A role for commands to be used to collect data

=head1 SYNOPSIS

    my $command = get_command('test');

    # new path
    set_command( test => '/usr/local/test' );

This is a role that is used to fetch the complete path of programs. The reason
to use a complete path instead of relative (I</bin/cat> instead of I<cat>) is a
security reason. When using relative paths, you might reach aliases, depending
on the configuration of the remote (or local) shell.

The idea is to make it easier for you to configure where your paths are, in case
the default one don't work (such as the difference between FreeBSD and
GNU/Linux.

=head1 ATTRIBUTES

=head2 commands(HashRef)

These are the set of commands. It comes with default locations for commands
used by core L<Data::Collector::Info> objects.

=head1 SUBROUTINES/METHODS

=head2 set_command

Sets a command's explicit path.

=head2 get_command

Gets a command's explicit path.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>
