package Data::Collector::Serializer::YAML;

use YAML;
use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

sub serialize {
    my ( $self, $data ) = @_;

    return Dump($data);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::Serializer::YAML - A YAML serializer for Data::Collector

Utilizes L<YAML>.

=head1 SUBROUTINES/METHODS

=head2 serialize

Gets data, serializes it and returns it.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>
