use blib;
use strict;
use warnings;
use Test::More tests => 1;
use Test::Perl::Critic;

#---------------------------------------------------------------------------

critic_ok('lib/Test/Perl/Critic.pm');

