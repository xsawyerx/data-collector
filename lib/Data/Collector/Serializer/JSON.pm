use strictures 1;
package Data::Collector::Serializer::JSON;
# ABSTRACT: A JSON serializer for Data::Collector

use JSON;
use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

sub serialize {
    my ( $self, $data ) = @_;

    return encode_json $data;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 DESCRIPTION

Utilizes L<JSON>.

=head1 SUBROUTINES/METHODS

=head2 serialize

Gets data, serializes it and returns it.

