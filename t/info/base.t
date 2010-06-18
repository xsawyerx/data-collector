#!perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;

use Sub::Override;
use Data::Collector::Info;

my $sub  = Sub::Override->new( 'Data::Collector::Info::info_keys' => sub {0} );
my $info = Data::Collector::Info->new;
isa_ok( $info, 'Data::Collector::Info' );

is( $info->load, 1, 'load() return value' );

$sub->restore;

throws_ok { $info->info_keys } qr/^No default info_keys method/;
throws_ok { $info->all       } qr/^No default all method/;

$info->register('key');
throws_ok { $info->register('key') } qr/^Sorry, key already reserved/;
$info->clear_registry();
lives_ok { $info->register('key') } 'Registry cleared';
