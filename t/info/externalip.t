#!perl
use strict;
use warnings;

use Test::More tests => 21;
use Test::Exception;

use Data::Collector::Info::ExternalIP;

{
    my $info = Data::Collector::Info::ExternalIP->new( raw_data => 'ack' );

    isa_ok( $info, 'Data::Collector::Info::ExternalIP' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 1, 'Correct number of keys' );

    is( $data->{'external_ip'}, 'ack', 'assigned external_ip' );
}

Data::Collector::Info->unregister(qw/ total_memory free_memory/);

{
    my $info = Data::Collector::Info::ExternalIP->new( raw_data => '10.0.0.1' );

    isa_ok( $info, 'Data::Collector::Info::ExternalIP' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 1, 'Correct number of keys' );

    is( $data->{'external_ip'}, '10.0.0.1', 'correct external_ip' );
}

{
    my $found = 0;
    {
        package Data::Collector::Engine::Fake;
        use Test::More;
        sub new { return bless {}, shift }
        sub run {
            isa_ok( $_[0], 'Data::Collector::Engine::Fake' );
            is( $_[1], 'mycurl myurl.com 2>/dev/null', 'correct engine cmd' );
            $found or return '10.0.0.1';
            $found == 1 and return 1;
            return;
        }
    }

    {
        no warnings qw/redefine once/;
        *Data::Collector::Info::ExternalIP::get_command = sub {
            isa_ok( $_[0], 'Data::Collector::Info::ExternalIP' );
            is( $_[1], 'curl', 'trying to get curl command' );
            return 'mycurl';
        };
    }

    my $engine = Data::Collector::Engine::Fake->new;
    my $info   = Data::Collector::Info::ExternalIP->new(
        url => 'myurl.com',
        engine => $engine,
    );

    is( $info->all->{'external_ip'}, '10.0.0.1', '_build_raw_data working' );

    $found++;
    throws_ok {
        $info->_build_raw_data;
    } qr/^Couldn't find IP in output/, 'parsing warning';

    $found++;
    throws_ok {
        $info->_build_raw_data;
    } qr/^Couldn't find IP in output/, 'parsing warning';
}
