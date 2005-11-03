use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile( NAME           => 'Test::Perl::Critic',
	       AUTHOR         => 'Jeffrey Thalhammer <thaljef@cpan.org>',
	       ABSTRACT_FROM  => 'lib/Test/Perl/Critic.pm',
	       VERSION_FROM   => 'lib/Test/Perl/Critic.pm',
	       PL_FILES       => {},
	       PREREQ_PM      => {'Perl::Critic'          => 0.09,
                                  'Test::More'            => 0,
                                  'File::Spec'            => 0,
			      },

);
