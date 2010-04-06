#!perl

use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

use Data::Collector::Info::Memory;

my $info;
throws_ok {
    $info = Data::Collector::Info::Memory->new() for 1, 2;
} qr/^Sorry, key already reserved/;


