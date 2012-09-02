package Data::Collector::Serializer::SimpleXML;
# ABSTRACT: A XML::Simple serializer for Data::Collector

use Moose;
use XML::Simple;
use namespace::autoclean;

sub serialize {
    my ( $self, $data ) = @_;

    return XMLout($data);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 DESCRIPTION

Utilizes L<XML::Simple>.

=head1 SUBROUTINES/METHODS

=head2 serialize

Gets data, serializes it and returns it.

