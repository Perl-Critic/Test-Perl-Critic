#######################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
########################################################################

use strict;
use warnings;
use Test::More tests => 13;
use Test::Perl::Critic;

#---------------------------------------------------------------------------

# Export tests
can_ok('main', 'critic_ok');
can_ok('main', 'all_critic_ok');

# Private sub tests
ok( Test::Perl::Critic::_is_perl( 'foo.pl' ) );
ok( Test::Perl::Critic::_is_perl( 'foo.pm' ) );
ok( Test::Perl::Critic::_is_perl( 'foo.PL' ) );
ok( Test::Perl::Critic::_is_perl( 'foo.t'  ) );

ok( ! Test::Perl::Critic::_is_perl( 'foo.tar' ) );
ok( ! Test::Perl::Critic::_is_perl( 'foo.pod' ) );
ok( ! Test::Perl::Critic::_is_perl( 'foo.txt' ) );
ok( ! Test::Perl::Critic::_is_perl( 'foo.gz'  ) );

my @files = ();
@files = Test::Perl::Critic::all_code_files('t');
ok(scalar @files == 8);

@files = Test::Perl::Critic::all_code_files('lib');
ok(scalar @files == 1);

@files = Test::Perl::Critic::all_code_files('lib', 't');
ok(scalar @files == 9);

