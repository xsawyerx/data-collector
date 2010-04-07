#!perl

use strict;
use warnings;

use Test::More tests => 7;
use Test::Exception;

use Sub::Override;
use Data::Collector;
use Data::Collector::Info::ExternalIP;
use Data::Collector::Engine::OpenSSH;

my $sub = Sub::Override->new;

$sub->replace( 'Data::Collector::Engine::OpenSSH::connect' => sub {1} );
$sub->replace( 'Data::Collector::Info::ExternalIP::_build_raw_data' => sub {
    return '1.1.1.1';
} );

{
    package Data::Collector::Engine::MyTest;
    use Moose;
    extends 'Data::Collector::Engine';
    sub run   {1}
}

my $engine = Data::Collector::Engine::MyTest->new();
isa_ok( $engine, 'Data::Collector::Engine::MyTest' );

my $collector = Data::Collector->new( engine_object => $engine );
isa_ok( $collector, 'Data::Collector' );

lives_ok { $collector->collect } 'Collecting once';

$engine->connected(1);

# double collecting not allowed
throws_ok { $collector->collect } qr/^Can't collect twice, buddy/;

$collector->clear_registry;
lives_ok { $collector->collect } 'Collecting again';

# fake some engine to allow testing of loading
lives_ok {
    $collector = Data::Collector->new(
        engine      => 'OpenSSH',
        engine_args => { host => 'heraldo' },
    );
} 'New collector without problems';

lives_ok {
    $collector->engine_object;
} 'Build engine successfully';
