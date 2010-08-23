use strictures 1;
package Data::Collector::Serializer::DataDumper;
# ABSTRACT: A Data::Dumper serializer for Data::Collector

use Data::Dumper;
use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

sub serialize {
    my ( $self, $data ) = @_;

    return Dumper $data;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 DESCRIPTION

Utilizes L<Data::Dumper>.

=head1 SUBROUTINES/METHODS

=head2 serialize

Gets data, serializes it and returns it.

