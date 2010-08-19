#!perl

use strict;
use warnings;

use Test::More tests => 12;
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

my $found = 0;

{
    no warnings qw/redefine once/;
    *Set::Object::contains = sub {
        isa_ok( $_[0], 'Set::Object',           'correct 1 parameter' );
        is(     $_[1], 'Data::Collector::Info', 'correct 2 parameter' );
        $found or return 1;
        return;
    };
}

lives_ok {
    $info = Data::Collector::Info->new;
} 'No problem if $INFO_MODULES->contains() actually contains';

$found++;

dies_ok { $info->BUILD } 'Dies';
