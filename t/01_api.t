#######################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
########################################################################

use strict;
use warnings;
use Test::More tests => 2;
use Test::Perl::Critic;

#---------------------------------------------------------------------------
# Export tests

can_ok('main', 'critic_ok');
can_ok('main', 'all_critic_ok');


