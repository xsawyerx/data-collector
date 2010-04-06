package Data::Collector::Serializer::SmartXML;

use Moose;
use XML::Smart;
use MooseX::StrictConstructor;
use namespace::autoclean;

sub serialize {
    my ( $self, $data ) = @_;

    my $xml = XML::Smart->new;

    foreach my $key ( keys %{$data} ) {
        $xml->{$key} = $data->{$key};
    }

    return $xml->data;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Data::Collector::Serializer::SmartXML - A XML::Smart serializer for
Data::Collector

Utilizes L<XML::Smart>.

=head1 SUBROUTINES/METHODS

=head2 serialize

Gets data, serializes it and returns it.

=head1 AUTHOR

Sawyer X, C<< <xsawyerx at cpan.org> >>
