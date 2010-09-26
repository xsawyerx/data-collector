#!perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;

use Sub::Override;
use Data::Collector;
use Data::Collector::Engine::OpenSSH;

my $sub = Sub::Override->new;

{
    package Data::Collector::Engine::MyTest;
    use Moose;
    extends 'Data::Collector::Engine';
    sub run {1}
}

{
    package Data::Collector::Info::EG;
    use Moose;
    extends 'Data::Collector::Info';
    sub info_keys { [] }
    sub all       { {} }
}

my $engine = Data::Collector::Engine::MyTest->new();
isa_ok( $engine, 'Data::Collector::Engine::MyTest' );

my $collector = Data::Collector->new(
    infos         => ['EG'],
    engine_object => $engine,
);

isa_ok( $collector, 'Data::Collector' );

lives_ok { $collector->collect } 'Collecting once';

$engine->connected(1);

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
