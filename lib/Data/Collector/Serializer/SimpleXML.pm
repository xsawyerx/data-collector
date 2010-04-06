package Data::Collector::Serializer::SimpleXML;

use Moose;
use XML::Simple;
use MooseX::StrictConstructor;
use namespace::autoclean;

sub serialize {
    my ( $self, $data ) = @_;

    return XMLout($data);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::Serializer::SimpleXML - A XML::Simple serializer for
Data::Collector

Utilizes L<XML::Simple>.

=head1 SUBROUTINES/METHODS

=head2 serialize

Gets data, serializes it and returns it.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>
