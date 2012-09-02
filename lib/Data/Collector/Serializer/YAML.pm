package Data::Collector::Serializer::YAML;
# ABSTRACT: A YAML serializer for Data::Collector

use YAML;
use Moose;
use namespace::autoclean;

sub serialize {
    my ( $self, $data ) = @_;

    return Dump($data);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 DESCRIPTION

Utilizes L<YAML>.

=head1 SUBROUTINES/METHODS

=head2 serialize

Gets data, serializes it and returns it.

