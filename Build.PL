#######################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
########################################################################

use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new(
    module_name    => 'Test::Perl::Critic',
    dist_author    => 'Jeffrey Thalhammer <thaljef@cpan.org>',
    dist_abstract  => 'Use Perl::Critic in test programs.',
    license        => 'perl',
    requires       => {
        'Carp'                      => 0,
        'English'                   => 0,
        'Perl::Critic'              => 1.082,
        'Perl::Critic::Utils'       => 1.082,
        'Perl::Critic::Violation'   => 1.082,
        'strict'                    => 0,
        'Test::Builder'             => 0,
        'warnings'                  => 0,
    },
    build_requires       => {
        'Test::More'                => 0,
    },
    meta_merge      => {
        resources   => {
            homepage    => 'http://perlcritic.com',
            license     => 'http://dev.perl.org/licenses/',
            Repository  => 'http://perlcritic.tigris.org/svn/perlcritic/trunk/Test-Perl-Critic/',
            MailingList => 'http://perlcritic.tigris.org/servlets/SummarizeList?listName=users',
        }
    },
);

$builder->create_build_script();
