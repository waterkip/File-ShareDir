use strict;
use warnings;

use ExtUtils::MakeMaker;

BEGIN
{
    unless (grep { $_ eq "." } @INC)
    {
        use lib ".";
    }
}

use inc::latest 'File::ShareDir::Install';
File::ShareDir::Install->import('0.03', 'install_share');

if (inc::latest->can("write"))
{
    inc::latest->write("inc");
    for my $mod (inc::latest->loaded_modules)
    {
        inc::latest->bundle_module($mod, "inc");
    }
}

install_share 'share';

# Full version
install_share module => 'File::ShareDir' => 'foo';

my %RUN_DEPS = (
    'warnings'         => 0,
    'Carp'             => 0,
    'Class::Inspector' => '1.12',
    'File::Spec'       => '0.80',
);
my %BUILD_DEPS = (
    'ExtUtils::MakeMaker'     => 0,
    'File::ShareDir::Install' => '0.03'
);
my %BUNDLE_CONFIGURE_DEPS = (
    'inc::latest'             => '0.500',
    'File::ShareDir::Install' => '0.08',
);
my %TEST_DEPS = (
    'Test::More' => 0.90,
);

WriteMakefile1(
    MIN_PERL_VERSION => '5.008001',
    META_ADD         => {
        'meta-spec' => {version => 2},
        resources   => {
            homepage   => 'https://metacpan.org/release/File-ShareDir',
            repository => {
                url  => 'git@github.com:perl5-utils/File-ShareDir.git',
                web  => 'https://github.com/perl5-utils/File-ShareDir',
                type => 'git',
            },
            bugtracker => {
                web    => 'http://rt.cpan.org/Public/Dist/Display.html?Name=File-ShareDir',
                mailto => 'file-sharedir@rt.cpan.org',
            },
        },
        prereqs => {
            develop => {
                requires => {
                    'Test::CPAN::Changes'                 => 0,
                    'Test::CheckManifest'                 => 0,
                    'Module::CPANTS::Analyse'             => '0.96',
                    'Test::Kwalitee'                      => 0,
                    'Test::Perl::Critic'                  => 0,
                    'Test::PerlTidy'                      => 0,
                    'Test::Pod'                           => 0,
                    'Test::Pod::Coverage'                 => 0,
                    'Test::Pod::Spelling::CommonMistakes' => 0,
                    'Test::Spelling'                      => 0,
                    %BUNDLE_CONFIGURE_DEPS,
                },
            },
            configure => {
                requires   => {%BUILD_DEPS},
                recommends => {%BUNDLE_CONFIGURE_DEPS}
            },
            build   => {requires => {%BUILD_DEPS}},
            test    => {requires => {%TEST_DEPS}},
            runtime => {
                requires   => {%RUN_DEPS},
                recommends => {
                    'Params::Util'    => '1.07',
                    'List::MoreUtils' => '0.428'
                },
            },
        },
    },
    NAME           => 'File::ShareDir',
    VERSION_FROM   => 'lib/File/ShareDir.pm',
    ABSTRACT_FROM  => 'lib/File/ShareDir.pm',
    LICENSE        => 'perl',
    AUTHOR         => q{Adam Kennedy <adamk@cpan.org>},
    PREREQ_PM      => \%RUN_DEPS,
    BUILD_REQUIRES => \%BUILD_DEPS,
    TEST_REQUIRES  => \%TEST_DEPS,
    (-d "xt" ? (realclean => {FILES => "inc/latest* inc/inc_* t/xs"}) : ()),
    test => {TESTS => 't/*.t xt/*.t'},
);

sub WriteMakefile1
{    # originally written by Alexandr Ciornii, version 0.21. Added by eumm-upgrade.
    my %params       = @_;
    my $eumm_version = $ExtUtils::MakeMaker::VERSION;
    $eumm_version = eval $eumm_version;
    die "EXTRA_META is deprecated" if (exists($params{EXTRA_META}));
    die "License not specified"    if (!exists($params{LICENSE}));
    if ($params{TEST_REQUIRES} and ($eumm_version < 6.6303))
    {
        if ($params{BUILD_REQUIRES})
        {
            $params{BUILD_REQUIRES} = {%{$params{BUILD_REQUIRES}}, %{$params{TEST_REQUIRES}}};
        }
        else
        {
            $params{BUILD_REQUIRES} = delete $params{TEST_REQUIRES};
        }
    }
    if ($params{BUILD_REQUIRES} and ($eumm_version < 6.5503))
    {
        #EUMM 6.5502 has problems with BUILD_REQUIRES
        $params{PREREQ_PM} = {%{$params{PREREQ_PM} || {}}, %{$params{BUILD_REQUIRES}}};
        delete $params{BUILD_REQUIRES};
    }
    delete $params{CONFIGURE_REQUIRES}    if ($eumm_version < 6.52);
    delete $params{MIN_PERL_VERSION}      if ($eumm_version < 6.48);
    delete $params{META_MERGE}            if ($eumm_version < 6.46);
    delete $params{META_ADD}{prereqs}     if ($eumm_version < 6.58);
    delete $params{META_ADD}{'meta-spec'} if ($eumm_version < 6.58);
    delete $params{META_ADD}              if ($eumm_version < 6.46);
    delete $params{LICENSE}               if ($eumm_version < 6.31);
    delete $params{AUTHOR}                if ($] < 5.005);
    delete $params{ABSTRACT_FROM}         if ($] < 5.005);
    delete $params{BINARY_LOCATION}       if ($] < 5.005);

    # more or less taken from Moose' Makefile.PL
    if ($params{CONFLICTS})
    {
        my $ok = CheckConflicts(%params);
        exit(0) if ($params{PREREQ_FATAL} and not $ok);
        my $cpan_smoker = grep { $_ =~ m/(?:CR_SMOKER|CPAN_REPORTER|AUTOMATED_TESTING)/ } keys %ENV;
        unless ($cpan_smoker || $ENV{PERL_MM_USE_DEFAULT})
        {
            sleep 4 unless ($ok);
        }
        delete $params{CONFLICTS};
    }

    WriteMakefile(%params);
}

package MY;

use File::ShareDir::Install qw(postamble);

1;
