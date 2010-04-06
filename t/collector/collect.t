#!perl

use strict;
use warnings;

use Test::More tests => 7;
use Test::Exception;

use Data::Collector;

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
use Sub::Override;
use Data::Collector::Engine::OpenSSH;
my $sub = Sub::Override->new(
    'Data::Collector::Engine::OpenSSH::connect' => sub {1}
);

lives_ok {
    $collector = Data::Collector->new(
        engine      => 'OpenSSH',
        engine_args => { host => 'heraldo' },
    );
} 'New collector without problems';

lives_ok {
    $collector->engine_object;
} 'Build engine successfully';
