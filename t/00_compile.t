use blib;
use strict;
use warnings;
use Test::More tests => 4;

#---------------------------------------------------------------------------

use_ok('Test::Perl::Critic');
can_ok('Test::Perl::Critic', 'critic_ok');
can_ok('Test::Perl::Critic', 'all_critic_ok');
can_ok('Test::Perl::Critic', 'all_code_files');
