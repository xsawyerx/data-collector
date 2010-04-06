use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Data::Collector',
    license             => 'perl',
    dist_author         => q{Sawyer X <xsawyerx@cpan.org>},
    dist_version_from   => 'lib/Data/Collector.pm',
    build_requires      => {
        'Test::More'      => 0,
        'Test::Exception' => 0,
        'Sub::Override'   => 0,
    },
    requires            => {
        'JSON'                      => 0,
        'Moose'                     => 0,
        'Set::Object'               => 0,
        'Data::Dumper'              => 0,
        'Net::OpenSSH'              => 0,
        'Module::Pluggable'         => 0,
        'namespace::autoclean'      => 0,
        'MooseX::StrictConstructor' => 0,
    },
    add_to_cleanup       => [ 'Data-Collector-*' ],
    create_makefile_pl   => 'traditional',
    create_readme        => 1,
    recursive_test_files => 1,
);

$builder->create_build_script();
