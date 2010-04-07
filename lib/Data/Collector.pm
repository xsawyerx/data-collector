package Data::Collector;

use Carp;
use Moose;
use MooseX::StrictConstructor;
use Module::Pluggable::Object;
use namespace::autoclean;

our $VERSION = '0.03';

has 'collected'     => ( is => 'rw', isa => 'Bool',    default => 0          );
has 'format'        => ( is => 'ro', isa => 'Str',     default => 'JSON'     );
has 'format_args'   => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has 'engine'        => ( is => 'ro', isa => 'Str',     default => 'OpenSSH'  );
has 'engine_args'   => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has 'engine_object' => (
    is         => 'ro',
    isa        => 'Object',
    lazy_build => 1,
);

has 'data' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => ['Hash'],
    default => sub { {} },
    handles => { add_data => 'set' },
);

sub _build_engine_object {
    my $self  = shift;
    my $type  = $self->engine;
    my $class = "Data::Collector::Engine::$type";

    eval "use $class";
    $@ && die "Can't load engine '$class': $@";

    return "Data::Collector::Engine::$type"->new( %{ $self->engine_args } );
}

sub collect {
    my $self   = shift;
    my $engine = $self->engine_object;

    # no double collecting
    $self->collected and croak "Can't collect twice, buddy\n" .
                               'Try clear_registry()';
    # lazy calling the connect
    $engine->connected or $engine->connect;

    my $object = Module::Pluggable::Object->new(
        search_path => 'Data::Collector::Info',
        require     => 1,
    );

    foreach my $class ( $object->plugins ) {
        my $info = $class->new( engine => $self->engine_object );
        my %data = %{ $info->all() };

        $self->add_data(%data);
    }

    $engine->connected and $engine->disconnect;

    $self->collected(1);

    return $self->serialize;
}

sub serialize {
    my $self   = shift;
    my $format = $self->format;
    my $class  = "Data::Collector::Serializer::$format";

    eval "use $class";
    $@ && die "Can't load serializer '$class': $@";

    my $serializer = $class->new( %{ $self->format_args } );

    return $serializer->serialize( $self->data );
}

sub clear_registry {
    my $self = shift;
    Data::Collector::Info->clear_registry;
    $self->collected(0);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector - Collect information from multiple sources - like Puppet's
Facter

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module collects various information from multiple sources and makes it
available in different formats.

    use Data::Collector;

    my $collector = Data::Collector->new(
        engine      => 'OpenSSH', # default
        engine_args => { password => read_password('Pass: ') },
        format      => 'JSON', # default
    );

    my %data = $collector->collect;
    ...

An important concept in Data::Collector is that it does not use any modules to
fetch the information, only shell commands. This might seem like a pain at first
but it allows it to be run on remote machines without any RPC server/client
set up. It might be changed in the future, but (at least now) it seems unlikely.

The main purpose of Data::Collector is to facilitate an information gatherning
subsystem, much like Puppet's Facter, to be used in system monitoring and
administration.

However, Data::Collector is much more dynamic. It supports any number of engines
and formats. Thus, it can be used for push or pull situations, can work with
monitoring systems, integrate with testing suites and otherwise a pretty wide
variety of situations.

=head1 ATTRIBUTES

=head2 engine(Str)

The engine that will be used to collect the information. This is the underlying
layer that will gather the information. The default is OpenSSH, you can use
any other one you want and even create your own.

By implementing your own, you can have fetching done via database queries,
online searching, local system commands or even telnet, if that's what you're
using.

=head2 engine_args(HashRef)

Any arguments that the engine might need. These are passed to the engine's
I<new> method. Other than making sure it's a hash reference, the value is not
checked and is left for the engine's discression.

L<Data::Collector::Engine::OpenSSH> requires a I<host>, and allows a I<user>
and I<passwd>.

=head2 format(Str)

This is the format in which you want the information. This will most likely
refer to the serializer you want, but it doesn't have to be. For example,
you could implement your own I<Serializer> which will actually be a module
to push all the changes you want in a database you have.

The default is JSON.

=head2 format_args(HashRef)

Much like I<engine_args>, you can supply any additional arguments that will
reach the serializer's I<new> method.

=head2 data(HashRef)

While (and post) collecting, this attribute contains all the information
[being] gathered. It is this data that is sent to the serializer in order
to do whatever it wants with it.

=head2 engine_object(Object)

This attributes holds the engine object. This should probably be left for
either testing or advanced usage. Please refrain from playing with it if
you're unsure how it works.

=head2 collected(Bool)

This is boolean attribute to indicate whether or not a collection has taken
place.

When running a collection twice, you will without a doubt trigger the registry
safe mechanism by trying to register every Info module again. In order to
provide a proper error msg indicting this, the C<collected> attribute is marked
after a collection.

If you clean the registry properly (using L<Data::Collector::Info>'s
C<clear_registry>), it will also clean up this boolean.

=head1 SUBROUTINES/METHODS

=head2 collect

The main function of Data::Collector. It runs all the information collecting
modules. When it is done, it runs the I<serialize> method in order to serialize
the information fetched.

=head2 serialize

Loads the serializer (according to the I<format> selected) and asks it to
serialize the data it collected.

This method can be run manually as well, but it is automatically run when
you run I<collect>.

=head2 clear_registry

Clears the information registry. The registry keeps all the keys of different
information modules. The registry makes sure information modules don't step on
each other.

However, this can prevent you from running collect more than once since it will
try to reregister all the information modules.

This method clears the registry B<and> clears out the C<collected> boolean,
allowing you to run I<collect> again.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-data-collector at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-Collector>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Data::Collector

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Collector>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Data-Collector>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Data-Collector>

=item * Search CPAN

L<http://search.cpan.org/dist/Data-Collector/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Sawyer X.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

