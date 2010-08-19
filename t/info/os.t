#!perl
use strict;
use warnings;

use Test::More tests => 16;

use Data::Collector::Info::OS;

my $found = 0;
{
    package Data::Collector::Engine::Fake;
    use Test::More;
    sub new { bless {}, shift }
    sub file_exists {
        isa_ok( $_[0], 'Data::Collector::Engine::Fake' );
        is( $_[1], '/etc/redhat-release', 'file_exists() redhat-release' );
        $found++ or return 1;
        return;
    }

    sub run {
        isa_ok( $_[0], 'Data::Collector::Engine::Fake' );
        is( $_[1], '/bin/cat /etc/redhat-release', 'run() cat redhat-release' );
        $found or return 'OS';
        return;
    }
}

my $fake = Data::Collector::Engine::Fake->new;

{
    my $info = Data::Collector::Info::OS->new(
        raw_data => 'ack',
        engine   => $fake,
    );

    isa_ok( $info, 'Data::Collector::Info::OS' );

    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 3, 'Correct number of keys' );

    is(   $data->{'os_name'   }, 'Linux',  'os_name'   );
    is(   $data->{'os_distro' }, 'CentOS', 'os_distro' );
    ok( ! $data->{'os_version'}, 'No os_version' );
}

Data::Collector::Info->unregister( qw/
    os_name os_distro os_version
/ );

{
    my $os   = '';
    my $info = Data::Collector::Info::OS->new(
        raw_data => $os, engine => $fake
    );

    isa_ok( $info, 'Data::Collector::Info::OS' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 3, 'Correct number of keys' );

    ok( ! $data->{'os_name'   }, 'No os_name'    );
    ok( ! $data->{'os_distro' }, 'No os_distro'  );
    ok( ! $data->{'os_version'}, 'No os_version' );
}

