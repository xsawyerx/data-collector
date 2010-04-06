#!perl
use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;

use JSON;
use Data::Collector::Serializer::JSON;

my $serializer = Data::Collector::Serializer::JSON->new();

{
    my $json = $serializer->serialize( { huck => '' } );
    my $data = q{};

    lives_ok { $data = decode_json $json } 'Decoded JSON successfully';

    cmp_ok( scalar keys ( %{$data} ), '==', 1, 'Correct number of keys' );

    ok( ! $data->{'huck'}, 'No huck' );
}

{
    my $json = $serializer->serialize( { huck => 'buck' } );
    my $data = q{};

    lives_ok { $data = decode_json $json } 'Decoded JSON successfully';

    cmp_ok( scalar keys ( %{$data} ), '==', 1, 'Correct number of keys' );

    is( $data->{'huck'}, 'buck', 'correct huck' );
}

