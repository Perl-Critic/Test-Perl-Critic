* [![Build Status](https://github.com/Perl-Critic/Test-Perl-Critic/workflows/testsuite/badge.svg?branch=dev)](https://github.com/Perl-Critic/Test-Perl-Critic/actions?query=workflow%3Atestsuite+branch%3Adev)
* [CPAN Testers](http://cpantesters.org/distro/T/Test-Perl-Critic.html)

# NAME

    Test::Perl::Critic - Use Perl::Critic in test programs

# SYNOPSIS

## Test one file:

      use Test::Perl::Critic;
      use Test::More tests => 1;
      critic_ok($file);

## Or test all files in one or more directories:

      use Test::Perl::Critic;
      all_critic_ok($dir_1, $dir_2, $dir_N );

## Or test all files in a distribution:

      use Test::Perl::Critic;
      all_critic_ok();

## Recommended usage for CPAN distributions:

      use strict;
      use warnings;
      use File::Spec;
      use Test::More;
      use English qw(-no_match_vars);

      if ( not $ENV{TEST_AUTHOR} ) {
          my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
          plan( skip_all => $msg );
      }

      eval { require Test::Perl::Critic; };

      if ( $EVAL_ERROR ) {
         my $msg = 'Test::Perl::Critic required to criticise code';
         plan( skip_all => $msg );
      }

      my $rcfile = File::Spec->catfile( 't', 'perlcriticrc' );
      Test::Perl::Critic->import( -profile => $rcfile );
      all_critic_ok();

# DESCRIPTION

Test::Perl::Critic wraps the Perl::Critic engine in a convenient
subroutine suitable for test programs written using the Test::More
framework. This makes it easy to integrate coding-standards enforcement
into the build process. For ultimate convenience (at the expense of some
flexibility), see the criticism pragma.

If you have an large existing code base, you might prefer to use
Test::Perl::Critic::Progressive, which allows you to clean your code
incrementally instead of all at once..

If you'd like to try Perl::Critic without installing anything, there is
a web-service available at <http://perlcritic.com>. The web-service does
not support all the configuration features that are available in the
native Perl::Critic API, but it should give you a good idea of what
Perl::Critic can do.

# SUBROUTINES

    all_critic_ok( [ @FILES ] )
        Runs "critic_ok()" for all Perl files in the list of @FILES. If a
        file is actually a directory, then all Perl files beneath that
        directory (recursively) will be run through "critic_ok()". If @FILES
        is empty or not given, then the blib/ is used if it exists, and if
        not, then lib/ is used. Returns true if all files are okay, or false
        if any file fails.

        This subroutine emits its own test plan, so you do not need to
        specify the expected number of tests or call "done_testing()".
        Therefore, "all_critic_ok" generally cannot be used in a test script
        that includes other sorts of tests.

        "all_critic_ok()" is also optimized to run tests in parallel over
        multiple cores (if you have them) so it is usually better to call
        this function than calling "critic_ok()" directly.

    critic_ok( $FILE [, $TEST_NAME ] )
        Okays the test if Perl::Critic does not find any violations in
        $FILE. If it does, the violations will be reported in the test
        diagnostics. The optional second argument is the name of test, which
        defaults to "Perl::Critic test for $FILE".

        If you use this form, you should load Test::More and emit your own
        test plan first or call "done_testing()" afterwards.

# CONFIGURATION

Perl::Critic is highly configurable. By default, Test::Perl::Critic
invokes Perl::Critic with its default configuration. But if you have
developed your code against a custom Perl::Critic configuration, you
will want to configure Test::Perl::Critic to do the same.

Any arguments passed through the "use" pragma (or via
"Test::Perl::Critic->import()" )will be passed into the Perl::Critic
constructor. So if you have developed your code using a custom
~/.perlcriticrc file, you can direct Test::Perl::Critic to use your
custom file too.

      use Test::Perl::Critic (-profile => 't/perlcriticrc');
      all_critic_ok();

Now place a copy of your own ~/.perlcriticrc file in the distribution as
t/perlcriticrc. Then, "critic_ok()" will be run on all Perl files in
this distribution using this same Perl::Critic configuration. See the
Perl::Critic documentation for details on the .perlcriticrc file format.

Any argument that is supported by the Perl::Critic constructor can be
passed through this interface. For example, you can also set the minimum
severity level, or include & exclude specific policies like this:

      use Test::Perl::Critic (-severity => 2, -exclude => ['RequireRcsKeywords']);
      all_critic_ok();

See the Perl::Critic documentation for complete details on its options
and arguments.

# DIAGNOSTIC DETAILS

By default, Test::Perl::Critic displays basic information about each
Policy violation in the diagnostic output of the test. You can customize
the format and content of this information by using the "-verbose"
option. This behaves exactly like the "-verbose" switch on the
perlcritic program. For example:

      use Test::Perl::Critic (-verbose => 6);

      #or...

      use Test::Perl::Critic (-verbose => '%f: %m at %l');

If given a number, Test::Perl::Critic reports violations using one of
the predefined formats described below. If given a string, it is
interpreted to be an actual format specification. If the "-verbose"
option is not specified, it defaults to 3.

        Verbosity     Format Specification
        -----------   -------------------------------------------------------
         1            "%f:%l:%c:%m\n",
         2            "%f: (%l:%c) %m\n",
         3            "%m at %f line %l\n",
         4            "%m at line %l, column %c.  %e.  (Severity: %s)\n",
         5            "%f: %m at line %l, column %c.  %e.  (Severity: %s)\n",
         6            "%m at line %l, near '%r'.  (Severity: %s)\n",
         7            "%f: %m at line %l near '%r'.  (Severity: %s)\n",
         8            "[%p] %m at line %l, column %c.  (Severity: %s)\n",
         9            "[%p] %m at line %l, near '%r'.  (Severity: %s)\n",
        10            "%m at line %l, column %c.\n  %p (Severity: %s)\n%d\n",
        11            "%m at line %l, near '%r'.\n  %p (Severity: %s)\n%d\n"

Formats are a combination of literal and escape characters similar to
the way "sprintf" works. See String::Format for a full explanation of
the formatting capabilities. Valid escape characters are:

        Escape    Meaning
        -------   ----------------------------------------------------------------
        %c        Column number where the violation occurred
        %d        Full diagnostic discussion of the violation (DESCRIPTION in POD)
        %e        Explanation of violation or page numbers in PBP
        %F        Just the name of the logical file where the violation occurred.
        %f        Path to the logical file where the violation occurred.
        %G        Just the name of the physical file where the violation occurred.
        %g        Path to the physical file where the violation occurred.
        %l        Logical line number where the violation occurred
        %L        Physical line number where the violation occurred
        %m        Brief description of the violation
        %P        Full name of the Policy module that created the violation
        %p        Name of the Policy without the Perl::Critic::Policy:: prefix
        %r        The string of source code that caused the violation
        %C        The class of the PPI::Element that caused the violation
        %s        The severity level of the violation

# CAVEATS

Despite the convenience of using a test script to enforce your coding
standards, there are some inherent risks when distributing those tests
to others. Since you don't know which version of Perl::Critic the
end-user has and whether they have installed any additional Policy
modules, you can't really be sure that your code will pass the
Test::Perl::Critic tests on another machine.

For these reasons, we strongly advise you to make your perlcritic tests
optional, or exclude them from the distribution entirely.

The recommended usage in the "SYNOPSIS" section illustrates one way to
make your perlcritic.t test optional. Another option is to put
perlcritic.t and other author-only tests in a separate directory (xt/
seems to be common), and then use a custom build action when you want to
run them. Also, you should not list Test::Perl::Critic as a requirement
in your build script. These tests are only relevant to the author and
should not be a prerequisite for end-use.

See <http://chrisdolan.net/talk/2005/11/14/private-regression-tests/>
for an interesting discussion about Test::Perl::Critic and other types
of author-only regression tests.

# FOR Dist::Zilla USERS

If you use Test::Perl::Critic with Dist::Zilla, beware that some DZ
plugins may mutate your code in ways that are not compliant with your
Perl::Critic rules. In particular, the standard
Dist::Zilla::Plugin::PkgVersion will inject a $VERSION declaration at
the top of the file, which will violate
Perl::Critic::Policy::TestingAndDebugging::RequireUseStrict. One
solution is to use the Dist::Zilla::Plugin::OurPkgVersion which allows
you to control where the $VERSION declaration appears.

# EXPORTS

      critic_ok()
      all_critic_ok()

# BUGS

If you find any bugs, please submit them to
https://github.com/Perl-Critic/Test-Perl-Critic/issues. Thanks.

# SEE ALSO

* Module::Starter::PBP
* Perl::Critic
* Test::More

# CREDITS

Andy Lester, whose Test::Pod module provided most of the code and
documentation for Test::Perl::Critic. Thanks, Andy.

# AUTHOR

Jeffrey Ryan Thalhammer <jeff@thaljef.org>

# COPYRIGHT

Copyright (c) 2005-2021 Jeffrey Ryan Thalhammer.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. The full text of this license can
be found in the LICENSE file included with this module.

