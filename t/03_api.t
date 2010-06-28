#######################################################################
#      $URL:  $
#     $Date:  $
#   $Author:  $
# $Revision:  $
########################################################################

use strict;
use warnings;
use Test::More tests => 1;
use Test::Perl::Critic;
use English qw(-no_match_vars);

# test to make sure critic_ok runs

critic_ok('lib/Test/Perl/Critic.pm')
