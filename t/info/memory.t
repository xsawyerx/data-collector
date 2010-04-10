#!perl
use strict;
use warnings;

use Test::More tests => 8;

use Data::Collector::Info::Memory;

{
    my $info = Data::Collector::Info::Memory->new( raw_data => 'ack' );

    isa_ok( $info, 'Data::Collector::Info::Memory' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 2, 'Correct number of keys' );

    ok( ! $data->{'total_memory'}, 'No total_memory' );
    ok( ! $data->{'free_memory'},  'No free_memory'  );
}

Data::Collector::Info->unregister(qw/ total_memory free_memory/);

{
    my $mem  = "MemTotal:        1014512 kB\nMemFree:           39948 kB\n";
    my $info = Data::Collector::Info::Memory->new( raw_data => $mem );

    isa_ok( $info, 'Data::Collector::Info::Memory' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 2, 'Correct number of keys' );

    is( $data->{'total_memory'}, '1014512', 'correct total_memory' );
    is( $data->{'free_memory'},  '39948',   'correct free_memory'  );
}

