#######################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
########################################################################

use 5.006001;

use strict;
use warnings;

use Module::Build;


my $class = Module::Build->subclass( code => <<'END_SUBCLASS' );

    sub ACTION_test {
        my ($self) = @_;

        $self->depends_on('manifest');

        return $self->SUPER::ACTION_test();
    }

    sub ACTION_authortest {
        my ($self) = @_;

        $self->depends_on('build');
        $self->depends_on('manifest');
        $self->depends_on('distmeta');

        $self->test_files( qw< t xt/author > );
        $self->recursive_test_files(1);

        $self->depends_on('test');

        return;
    } # end ACTION_authortest()

    sub ACTION_distdir {
        my ($self) = @_;

        $self->depends_on('authortest');

        return $self->SUPER::ACTION_distdir;
    } # end ACTION_distdir

END_SUBCLASS

my $builder = $class->new(
    module_name     => 'Test::Perl::Critic',
    dist_author     => 'Jeffrey Thalhammer <thaljef@cpan.org>',
    dist_abstract   => 'Use Perl::Critic in test programs.',
    license         => 'perl',
    dynamic_config  => 1,
    create_readme   => 1,
    create_packlist => 1,
    sign            => 0,

    requires        => {
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
