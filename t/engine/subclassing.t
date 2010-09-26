#!perl

package main;
use strict;
use warnings;

use Test::More tests => 12;
use Test::Exception;

use Sub::Override;
use Data::Collector;

my $sub = Sub::Override->new;

{
    my $collector = Data::Collector->new( engine => 'MyTest' );

    isa_ok( $collector, 'Data::Collector' );
    dies_ok { $collector->collect } qr/^No default run method$/;
}

{
    package Data::Collector::Engine::MyTest;
    use Moose;
    extends 'Data::Collector::Engine';
    sub run { shift->connected(1) }
}

{
    package Data::Collector::Info::EG;
    use Moose;
    extends 'Data::Collector::Info';
    sub info_keys { [] }
    sub all       { {} }
}

{
    my $engine = Data::Collector::Engine::MyTest->new();
    isa_ok( $engine, 'Data::Collector::Engine::MyTest' );

    my $collector = Data::Collector->new(
        infos         => ['EG'],
        engine_object => $engine
    );

    isa_ok( $collector, 'Data::Collector' );
    isa_ok( $collector->engine_object, 'Data::Collector::Engine::MyTest' );

    my ( $connect, $disconnect );

    $sub->replace( 'Data::Collector::Engine::connect',    sub { $connect++    } );
    $sub->replace( 'Data::Collector::Engine::disconnect', sub { $disconnect++ } );

    $collector->collect;

    ok( $connect,    'Reached connect'    );
    ok( $disconnect, 'Reached disconnect' );
}

{
    my $engine = Data::Collector::Engine->new;
    isa_ok( $engine, 'Data::Collector::Engine' );
    dies_ok { $engine->run } qr/^No default run method$/;

    my ( $connect, $disconnect );

    $sub->replace( 'Data::Collector::Engine::run' => sub {
        shift->connected(1);
    } );
    $sub->replace( 'Data::Collector::Engine::connect',    sub { $connect++    } );
    $sub->replace( 'Data::Collector::Engine::disconnect', sub { $disconnect++ } );

    $engine->run;
    $engine->connect;
    $engine->disconnect;

    ok( $engine->connected, 'Mark as connected' );
    ok( $connect,    'Reached connect'    );
    ok( $disconnect, 'Reached disconnect' );
}

