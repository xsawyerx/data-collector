#!perl

use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

use Data::Collector::Info::Memory;

{
    package Data::Collector::Info::One;
    use Moose;
    extends 'Data::Collector::Info';
    sub load { Data::Collector::Info->register('this') }

    package Data::Collector::Info::Two;
    use Moose;
    extends 'Data::Collector::Info';
    sub load { Data::Collector::Info->register('this') }
}

my $info;
throws_ok {
    $info = Data::Collector::Info::One->new();
    $info = Data::Collector::Info::Two->new();
} qr/^Sorry, key already reserved/;


