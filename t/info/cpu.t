#!perl
use strict;
use warnings;

use Test::More tests => 12;

use Data::Collector::Info::CPU;

{
    my $info = Data::Collector::Info::CPU->new( raw_data => 'ack' );

    isa_ok( $info, 'Data::Collector::Info::CPU' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 4, 'Correct number of keys' );

    ok( ! $data->{'cpu_flags'     }, 'No cpu_flags'      );
    ok( ! $data->{'cpu_model'     }, 'No cpu_model'      );
    ok( ! $data->{'cpu_mhz'       }, 'No cpu_mhz'        );
    ok( ! $data->{'number_of_cpus'}, 'No number_of_cpus' );
}

Data::Collector::Info->unregister( qw/
    cpu_flags cpu_model cpu_mhz number_of_cpus
/ );

{
    my $mhz   = '800.000';
    my $model = 'Intel(R) thing';
    my $flags = 'fpu vme';
    my $proc  = 'processor : yes';
    my $cpu   = "cpu MHz : $mhz\nflags : $flags\nmodel name : $model\n$proc\n";
    my $info  = Data::Collector::Info::CPU->new( raw_data => $cpu );

    isa_ok( $info, 'Data::Collector::Info::CPU' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 4, 'Correct number of keys' );

    is( $data->{'number_of_cpus'}, 1,                'correct number_of_cpus' );
    is( $data->{'cpu_flags'     }, 'fpu vme',        'correct cpu_flags'      );
    is( $data->{'cpu_model'     }, 'Intel(R) thing', 'correct cpu_model'      );
    is( $data->{'cpu_mhz'       }, '800.000',        'correct cpu_mhz'        );
}

