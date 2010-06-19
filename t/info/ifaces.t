#!perl
use strict;
use warnings;

use Test::More tests => 15;

use Data::Collector::Info::IFaces;

{
    my $info = Data::Collector::Info::IFaces->new( raw_data => 'ack' );

    isa_ok( $info, 'Data::Collector::Info::IFaces' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 1, 'Correct number of keys' );

    is_deeply( $data->{'ifaces'}, {}, 'No ifaces' );
}

Data::Collector::Info->unregister('ifaces');

my $iface = <<'__END_';
wlan0     Link encap:Ethernet  HWaddr 00:22:fa:eb:67:02  
          inet addr:192.168.1.106  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::222:faff:feeb:6702/64 Scope:Link
__END_

{
    my $info  = Data::Collector::Info::IFaces->new( raw_data => $iface );

    isa_ok( $info, 'Data::Collector::Info::IFaces' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 1, 'Correct number of keys' );

    is_deeply(
        $data->{'ifaces'},
        { 'wlan0' => '192.168.1.106' },
        'correct ifaces',
    );
}

{
    my $info  = Data::Collector::Info::IFaces->new(
        raw_data  => $iface,
        ignore_ip => ['192.168.1.106'],
    );

    isa_ok( $info, 'Data::Collector::Info::IFaces' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 1, 'Correct number of keys' );
    is_deeply( $data->{'ifaces'}, {}, 'ignore_ip option' );
}

{
    my $info  = Data::Collector::Info::IFaces->new(
        raw_data     => $iface,
        ignore_iface => ['wlan0'],
    );

    isa_ok( $info, 'Data::Collector::Info::IFaces' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 1, 'Correct number of keys' );
    is_deeply( $data->{'ifaces'}, {}, 'ignore_iface option' );
}

{
    my $info = Data::Collector::Info::IFaces->new( raw_data => '' );
    $info->all;

    isa_ok( $info, 'Data::Collector::Info::IFaces' );
    my $data = $info->all;

    cmp_ok( scalar keys ( %{$data} ), '==', 1, 'Correct number of keys' );
    is_deeply( $data->{'ifaces'}, {}, 'no ifaces' );
}
