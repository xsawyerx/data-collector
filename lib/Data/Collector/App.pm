package Data::Collector::App;

use Moose;
use Module::Pluggable::Object;
use MooseX::Types::Path::Class 'File';
use namespace::autoclean;

use Data::Collector;

with qw/ MooseX::SimpleConfig MooseX::Getopt::Dashes /;

has '+configfile' => ( default => '/etc/data_collector.yaml' );

has 'engine' => ( is => 'ro', isa => 'Str', default => 'OpenSSH' );
has 'format' => ( is => 'ro', isa => 'Str', default => 'JSON'    );

has 'output' => (
    is        => 'ro',
    isa       => File,
    predicate => 'has_output',
);

has [ qw/ engine_args format_args info_args / ] => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

my @classes = Module::Pluggable::Object->new(
    search_path => 'Data::Collector::Info'
)->plugins;

foreach my $class (@classes) {
    my @classes = split /\:\:/, $class;
    my $info    = lc $classes[-1];
    my $attr    = "info_${info}_args";

    if ( __PACKAGE__->meta->get_attribute($attr) ) {
        die "Already have attribute by the name of $attr\n";
    }

    has $attr => (
        is      => 'ro',
        isa     => 'HashRef',
        default => sub { {} },
    );
}

sub BUILD {
    my $self  = shift;
    my $regex = qr/^info_(.+)_args$/;

    foreach my $attr ( $self->meta->get_attribute_list ) {
        if ( $attr =~ $regex ) {
            $self->info_args->{$1} = $self->$attr;
        }
    }
}

sub run {
    my $self      = shift;
    my $collector = Data::Collector->new(
        engine      => $self->engine,
        engine_args => $self->engine_args,
        format      => $self->format,
        format_args => $self->format_args,
        info_args   => $self->info_args,
    );

    my $data = $collector->collect;

    if ( $self->has_output ) {
        my $file = $self->output;        
        write_file( $file, $data );
    } else {
        print "$data\n";
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::App - An application implementation for Data::Collector

Using this implementation, one can write an application.

=head1 SYNOPSIS

    use Data::Collector::App;

    my $collector = Data::Collector::App->new_with_options();
    $collector->run();

This module integrates all the checks and logics of an application.

It supports getopt command line parsing and optional configuration files.

=head1 ATTRIBUTES

=head2 configfile

An optional configuration file. If it exists, it is read and used for the
value of the rest of these attributes (if they are present in the file).

Default: C</etc/data_collector.yaml>.

=head2 engine

Type of engine (OpenSSH, for example).

=head2 engine_args

Any additional arguments the engine might want.

=head2 format

Type of serialization (C<JSON> or C<YAML>, for example).

=head2 format_args

Any additional arguments the serializer might want.

=head2 info_args

Any additional arguments the Info module might want.

=head2 output

A file to output to. If one is not provided, it will output the serialized
result to stdout.

=head1 SUBROUTINES/METHODS

=head2 new

Creates a new instance of the application interface. This is the clean way of
doing it. You would probably prefer C<new_with_options> described below.

=head2 new_with_options

The same as C<new>, only it parses command line arguments and takes care of
reading a configuration file (if the correct argument for it is provided).

=head2 run

Runs the application: starts a new collector, collects the informtion and -
depending on the options - either outputs the result to the screen or to a
file.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>
