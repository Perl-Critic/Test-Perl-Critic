#######################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
########################################################################

package Test::Perl::Critic;

use strict;
use warnings;
use Carp qw(croak);
use English qw(-no_match_vars);
use Test::Builder qw();
use Perl::Critic qw();
use Perl::Critic::Violation qw();
use Perl::Critic::Utils;

our $VERSION = 0.08;

#---------------------------------------------------------------------------

my $TEST        = Test::Builder->new();
my %CRITIC_ARGS = ();

#---------------------------------------------------------------------------

sub import {

    my ( $self, %args ) = @_;
    my $caller = caller;

    no strict 'refs';  ## no critic
    *{ $caller . '::critic_ok' }     = \&critic_ok;
    *{ $caller . '::all_critic_ok' } = \&all_critic_ok;

    $TEST->exported_to($caller);

    # -format is supported for backward compatibility
    if( exists $args{-format} ){ $args{-verbose} = $args{-format}; }
    %CRITIC_ARGS = %args;

    return 1;
}

#---------------------------------------------------------------------------

sub critic_ok {

    my ( $file, $test_name ) = @_;
    croak q{no file specified} if not defined $file;
    croak qq{"$file" does not exist} if not -f $file;
    $test_name ||= qq{Test::Perl::Critic for "$file"};

    my $critic = undef;
    my @violations = ();
    my $ok = 0;

    # Run Perl::Critic
    eval {
        # TODO: Should $critic be a global singleton?
        $critic     = Perl::Critic->new( %CRITIC_ARGS );
        @violations = $critic->critique( $file );
        $ok         = not scalar @violations;
    };

    # Evaluate results
    $TEST->ok( $ok, $test_name );


    if ($EVAL_ERROR) {           # Trap exceptions from P::C
        $TEST->diag( "\n" );     # Just to get on a new line.
        $TEST->diag( qq{Perl::Critic had errors in "$file":} );
        $TEST->diag( qq{\t$EVAL_ERROR} );
    }
    elsif ( not $ok ) {          # Report Policy violations
        $TEST->diag( "\n" );     # Just to get on a new line.
        $TEST->diag( qq{Perl::Critic found these violations in "$file":} );

        my $verbose = $critic->config->verbose();
        Perl::Critic::Violation::set_format( $verbose );
        for my $viol (@violations) { $TEST->diag("$viol") }
    }

    return $ok;
}

#---------------------------------------------------------------------------

sub all_critic_ok {

    my @dirs = @_ ? @_ : _starting_points();
    my @files = all_code_files( @dirs );
    $TEST->plan( tests => scalar @files );

    my $okays = grep { critic_ok($_) } @files;
    return $okays == @files;
}

#---------------------------------------------------------------------------

sub all_code_files {
    my @dirs = @_ ? @_ : _starting_points();
    return Perl::Critic::Utils::all_perl_files(@dirs);
}

#---------------------------------------------------------------------------

sub _starting_points {
    return -e 'blib' ? 'blib' : 'lib';
}

#---------------------------------------------------------------------------

1;


__END__

=pod

=head1 NAME

Test::Perl::Critic - Use Perl::Critic in test programs

=head1 SYNOPSIS

  use Test::Perl::Critic;

  critic_ok($file);                          #Test one file
  all_critic_ok($dir_1, $dir_2, $dir_N );    #Test all files in several $dirs
  all_critic_ok()                            #Test all files in distro

=head1 DESCRIPTION

Test::Perl::Critic wraps the L<Perl::Critic> engine in a convenient
subroutine suitable for test programs written using the L<Test::More>
framework.  This makes it easy to integrate coding-standards
enforcement into the build process.  For ultimate convenience (at the
expense of some flexibility), see the L<criticism> pragma.

=head1 SUBROUTINES

=over 8

=item critic_ok( FILE [, TEST_NAME ] )

Okays the test if Perl::Critic does not find any violations in FILE.
If it does, the violations will be reported in the test diagnostics.
The optional second argument is the name of test, which defaults to
"Perl::Critic test for FILE".

=item all_critic_ok( [@DIRECTORIES] )

Runs C<critic_ok()> for all Perl files beneath the given list of
directories.  If given an empty list, the function tries to find all
Perl files in the F<blib/> directory.  If the F<blib/> directory does
not exist, then it tries the F<lib/> directory.  Returns true if all
files are okay, or false if any file fails.

If you are building a module with the usual CPAN directory structure,
just make a F<t/perlcritic.t> file like this:

  use Test::Perl::Critic;
  all_critic_ok();

Or if you use the latest version of L<Module::Starter::PBP>, it will
generate this and several other standard test programs for you.

=item all_code_files ( [@DIRECTORIES] )

B<DEPRECATED:> Use the C<all_perl_files> subroutine that is exported
by L<Perl::Critic::Utils> instead.

Returns a list of all the Perl files found beneath each DIRECTORY, If
@DIRECTORIES is an empty list, defaults to F<blib/>.  If F<blib/> does
not exist, it tries F<lib/>.  Skips any files in CVS or Subversion
directories.

A Perl file is:

=over 4

=item * Any file that ends in F<.PL>, F<.pl>, F<.pm>, or F<.t>

=item * Any file that has a first line with a shebang containing 'perl'

=back

=back

=head1 CONFIGURATION

L<Perl::Critic> is highly configurable.  By default,
Test::Perl::Critic invokes Perl::Critic with it's default
configuration.  But if you have developed your code against a custom
Perl::Critic configuration, you will want to configure
Test::Perl::Critic to do the same.

Any arguments given to the C<use> pragma will be passed into the
L<Perl::Critic> constructor.  So if you have developed your code using
a custom F<~/.perlcriticrc> file, you can ask Test::Perl::Critic to
use a custom file too.

  use Test::Perl::Critic (-profile => 't/perlcriticrc');
  all_critic_ok();

Now place a copy of your own F<~/.perlcriticrc> file in the distribution
as F<t/perlcriticrc>.  Then, C<critic_ok()> will be run on all Perl
files in this distribution using this same Perl::Critic configuration.
See the L<Perl::Critic> documentation for details on the
F<.perlcriticrc> file format.

Any argument that is supported by the L<Perl::Critic> constructor can
be passed through this interface.  For example, you can also set the
minimum severity level, or include & exclude specific policies like
this:

  use Test::Perl::Critic (-severity => 2, -exclude => ['RequireRcsKeywords']);
  all_critic_ok();

See the L<Perl::Critic> documentation for complete details on it's
options and arguments.

=head1 DIAGNOSTIC DETAILS

By default, Test::Perl::Critic displays basic information about each
Policy violation in the diagnostic output of the test.  You can
customize the format and content of this information by giving an
additional C<-verbose> option to the C<use> pragma.  This behaves
exactly like the C<-verbose> switch on the F<perlcritic> program.  For
example:

  use Test::Perl::Critic (-verbose => 6);

  #or...

  use Test::Perl::Critic (-verbose => '%f: %m at %l');

If given a number, Test::Perl::Critic reports violations using one of
the predefined formats described below. If given a string, it is
interpreted to be an actual format specification. If the -verbose
option is not specified, it defaults to 3.

    Verbosity     Format Specification
    -----------   --------------------------------------------------------------------
     1            "%f:%l:%c:%m\n",
     2            "%f: (%l:%c) %m\n",
     3            "%m at line %l, column %c.  %e.  (Severity: %s)\n",
     4            "%f: %m at line %l, column %c.  %e.  (Severity: %s)\n",
     5            "%m at line %l, near '%r'.  (Severity: %s)\n",
     6            "%f: %m at line %l near '%r'.  (Severity: %s)\n",
     7            "[%p] %m at line %l, column %c.  (Severity: %s)\n",
     8            "[%p] %m at line %l, near '%r'.  (Severity: %s)\n",
     9            "%m at line %l, column %c.\n  %p (Severity: %s)\n%d\n",
    10            "%m at line %l, near '%r'.\n  %p (Severity: %s)\n%d\n"

Formats are a combination of literal and escape characters similar to
the way sprintf works. See String::Format for a full explanation of
the formatting capabilities. Valid escape characters are:

    Escape    Meaning
    -------   ------------------------------------------------------------------------
    %m        Brief description of the violation
    %f        Name of the file where the violation occurred.
    %l        Line number where the violation occurred
    %c        Column number where the violation occurred
    %e        Explanation of violation or page numbers in PBP
    %d        Full diagnostic discussion of the violation
    %r        The string of source code that caused the violation
    %P        Name of the Policy module that created the violation
    %p        Name of the Policy without the Perl::Critic::Policy:: prefix
    %s        The severity level of the violation

=head1 CAVEATS

Despite the obvious convenience of using test programs to verify that
your code complies with coding standards, it is not really sensible to
distribute your module with those test programs.  You don't know which
version of Perl::Critic the user has and whether they have installed
additional Policy modules, so you can't really be sure that your code
will pass the Test::Perl::Critic tests on another machine.

The easy solution is to add your F<perlcritic.t> test program to the
F<MANIFEST.SKIP> file.  When you test your build, you'll still be able
to run the Perl::Critic tests with C<"make test">, but they won't be
included in the tarball when you C<"make dist">.

See L<http://www.chrisdolan.net/talk/index.php/2005/11/14/private-regression-tests/>
for an interesting discussion about Test::Perl::Critic and other types
of author-only regression tests.

=head1 EXPORTS

  critic_ok()
  all_critic_ok()

=head1 PERFORMANCE HACKS

If you want a small performance boost, you can tell PPI to cache
results from previous parsing runs.  Most of the processing time is in
Perl::Critic, not PPI, so the speedup is not huge (only about 20%).
Nonetheless, if your distribution is large, it's worth the effort.

Add a block of code like the following to your test program, probably
just before the call to C<all_critic_ok()>.  Be sure to adjust the
path to the temp directory appropriately for your system.

    use File::Spec;
    my $cache_path = File::Spec->catdir(File::Spec->tmpdir,
                                        "test-perl-critic-cache-$ENV{USER}");
    if (!-d $cache_path) {
       mkdir $cache_path, oct 700;
    }
    require PPI::Cache;
    PPI::Cache->import(path => $cache_path);

We recommend that you do NOT use this technique for tests that will go
out to end-users.  They're probably going to only run the tests once,
so they will not see the benefit of the caching but will still have
files stored in their temp directory.

=head1 BUGS

Please report all bugs to L<http://rt.cpan.org>.  Thanks.

=head1 SEE ALSO

L<Module::Starter::PBP>

L<Perl::Critic>

L<Test::More>

=head1 CREDITS

Andy Lester, whose L<Test::Pod> module provided most of the code and
documentation for Test::Perl::Critic.  Thanks, Andy.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2006 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
