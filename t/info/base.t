#!perl

use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

use Data::Collector::Info;

my $info = Data::Collector::Info->new;
isa_ok( $info, 'Data::Collector::Info' );

is( $info->load, 1, 'load() return value' );

throws_ok { $info->all } qr/^No default all method/;
