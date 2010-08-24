use strictures 1;
package Data::Collector::Info::OS;
# ABSTRACT: Fetch machine OS information

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

extends 'Data::Collector::Info';
with    'Data::Collector::Commands';

has [ qw/ os_name os_version os_distro / ] => (
    is => 'rw', isa => 'Str'
);

has 'types' => (
    is      => 'ro',
    isa     => 'HashRef[HashRef[Str|CodeRef]]',
    default => sub { {
        'CentOS' => {
            name    => 'Linux',
            file    => '/etc/redhat-release',
            version => sub {
                my ( $self, $data ) = @_;
                $data   ||= q{};
                my $regex = qr/
                    ^CentOS \s release \s
                    (\d+) (\.\d+)? (?: \s \(Final\) )?
                /x;

                if ( $data =~ $regex ) {
                    $self->os_version( $2 ? $1 . $2 : $1 );
                    return 1;
                }
            },
        },

        'Fedora' => {
            name    => 'Linux',
            file    => '/etc/redhat-release',
            version => sub {
                my ( $self, $data ) = @_;
                $data   ||= q{};
                my $regex = qr/
                    ^Fedora \s release \s
                    (\d+) (\.\d+)?
                /x;

                if ( $data =~ $regex ) {
                    $self->os_version( $2 ? $1 . $2 : $1 );
                    return 1;
                }
            },
        },
    } },
);

sub info_keys { [qw/ os_name os_distro os_version /] }

sub all {
    my $self   = shift;
    my %types  = %{ $self->types };
    my $engine = $self->engine;
    my $cat    = $self->get_command('cat');

    foreach my $distro ( keys %types ) {
        my $file = $types{$distro}->{'file'};
        my $cb   = $types{$distro}->{'version'};

        if ( $self->engine->file_exists($file) ) {
            my $data = $self->engine->run("$cat $file");
            if ( $cb->( $self, $data ) ) {
                $self->os_name( $types{$distro}->{'name'} );
                $self->os_distro($distro);

                last;
            }
        }
    }

    return {
        os_name    => $self->os_name,
        os_distro  => $self->os_distro,
        os_version => $self->os_version,
    };
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 DESCRIPTION

This info module fetches information about a machine's OS details using version
files such as C</etc/redhat-release> for Red Hat or CentOS.

Current there is only support for CentOS. Patches are welcome. :)

The keys this module takes in the registry are I<os_name>, I<os_distro> and
I<os_version>.

=head1 SUBROUTINES/METHODS

=head2 info_keys

Subclassing C<info_keys> from L<Data::Collector::Info> to indicate which keys
to register.

=head2 all

Fetches and returns the details in a unified hashref.

