package Test::Perl::Critic;

use strict;
use warnings;
use English qw(-no_match_vars);
use Test::Builder;
use Perl::Critic;
use File::Spec;

our $VERSION = '0.03';
$VERSION = eval $VERSION;    ## no critic

my $TEST    = Test::Builder->new();
my $PROFILE = undef;
my $FORMAT  = undef;

#---------------------------------------------------------------------------

sub import {
    my ( $self, %args ) = @_;
    my $caller = caller;

    no strict 'refs';
    *{ $caller . '::critic_ok' }     = \&critic_ok;
    *{ $caller . '::all_critic_ok' } = \&all_critic_ok;

    $TEST->exported_to($caller);
    $FORMAT  = $args{-format}  || "\t%m at line %l, column %c. %e";
    $PROFILE = $args{-profile} || q{};
}

#---------------------------------------------------------------------------

sub critic_ok {

    my ( $file, $name ) = @_;
    $name ||= "Test::Perl::Critic for $file";
    my @violations = ();
    my $ok = 0;

    if ( !-f $file ) {
        $TEST->ok( 0, $name );
        $TEST->diag("$file does not exist");
        return;
    }

    eval {
	my $critic  = Perl::Critic->new( -profile => $PROFILE );
	@violations = $critic->critique($file);
	$ok         = !scalar @violations;
    };
    
    # Evaluate results
    $TEST->ok( $ok, $name );


    if ($EVAL_ERROR) {  # Trap exceptions from P::C
	$TEST->diag( "\n" );     #Just to get on a new line.
        $TEST->diag( qq{Perl::Critic had errors in '$file':} );
	$TEST->diag( qq{\t$EVAL_ERROR} );
    }
    elsif ( !$ok ) {    # Report Policy violations
        $TEST->diag( "\n" );         #Just to get on a new line.
        $TEST->diag( qq{Perl::Critic found these violations in '$file':} );
	$FORMAT =~ s{\%f}{$file}gmx; #HACK! Violation doesn't know the file
	no warnings 'once';         #Ugh. It's tough to be a perfectionist.
	local $Perl::Critic::Violation::FORMAT = $FORMAT;  ## no critic
        for my $viol (@violations) { $TEST->diag("$viol") }
    }

    return $ok;
}

#---------------------------------------------------------------------------

sub all_critic_ok {

    my @files = all_code_files(@_);
    $TEST->plan( tests => scalar @files );

    my $ok = 1;
    for my $file (@files) {
        critic_ok( $file, $file ) or undef $ok;
    }
    return $ok;
}

#---------------------------------------------------------------------------

sub all_code_files {

    my @queue      = @_ ? @_ : _starting_points();
    my @code_files = ();

    while (@queue) {
        my $file = shift @queue;
        if ( -d $file ) {
            opendir my ($dh), $file or next;
            my @newfiles = readdir $dh;
            closedir $dh;

            @newfiles = File::Spec->no_upwards(@newfiles);
            @newfiles = grep { $_ ne 'CVS' && $_ ne '.svn' } @newfiles;

            push @queue, map { "$file/$_" } @newfiles;
        }

        if ( -f $file && _is_perl($file) ) {
            push @code_files, $file;
        }
    }
    return @code_files;
}

#---------------------------------------------------------------------------

sub _starting_points {
    return -e 'blib' ? 'blib' : 'lib';
}

#---------------------------------------------------------------------------
sub _is_perl {
    my $file = shift;

    #Check filename extensions
    return 1 if $file =~ m{ [.] PL          \z}mx;
    return 1 if $file =~ m{ [.] p (?: l|m ) \z}mx;
    return 1 if $file =~ m{ [.] t           \z}mx;

    #Check for shebang
    open my ($fh), $file or return;
    my $first = <$fh>;
    close $fh;

    return 1 if defined $first && ( $first =~ m{ \A \#!.*perl }mx );
    return;
}

1;

#---------------------------------------------------------------------------

__END__

=head1 NAME

Test::Perl::Critic - Use Perl::Critic in test scripts

=head1 SYNOPSIS

  use Test::Perl::Critic;

  critic_ok($file);                          #Test one file
  all_critic_ok($dir_1, $dir_2, $dir_N );    #Test all files in several $dirs
  all_critic_ok()                            #Test all files in distro

=head1 DESCRIPTION

Test::Perl::Critic wraps the L<Perl::Critic> engine in a convenient
subroutine suitable for test scripts written for L<Test::Harness>.
This makes it easy to integrate coding-standards enforcement into the
build process.

=head1 SUBROUTINES

=over 8

=item critic_ok( FILE [, TESTNAME ] )

Okays the test if Perl::Critic does not find any violations in FILE.
If it does, the violations will be reported in the test diagnostics.
The optional second argument is the name of test, which defaults to
"Perl::Critic test for FILE".

=item all_critic_ok( @DIRECTORIES )

Runs C<critic_ok()> for all Perl files beneath the given list of
directories.  If given an empty list, the function tries to find all
Perl files in the F<blib/> directory.  If the F<blib/> directory does
not exist, then it tries the F<lib/> directory.

If you are testing a module, just make a F<t/criticize.t> file with
this:

  use Test::More;
  eval 'use Test::Perl::Critic';
  plan skip_all => 'Test::Perl::Critic required to criticise code' if $@;
  all_critic_ok();

Returns true if all files are ok, or false if any file fails.

=item all_code_files ( [@DIRECTORIES] )

Returns a list of all the Perl files found beneath each DIRECTORY, If
@DIRECTORIES is an empty list, defaults to F<blib/>.  If F<blib/> does
not exist, it tries F<lib/>.  Skips any files in CVS or .svn
directories.

A Perl file is:

=over 4

=item * Any file that ends in F<.PL>, F<.pl>, F<.pm>, or F<.t>

=item * Any file that has a first line with a shebang containing 'perl'

=back

=back

=head1 CONFIGURATION

L<Perl::Crtic> is highly configurable.  By default, Test::Perl::Critic
invokes Perl::Critic with its default configuration.  But if you have
developed your code against a custom Perl::Critic configuration,
you will want to configure Test::Perl::Critic to do the same.

Test::Perl::Critic allows you to configure Perl::Critic by passing the
path to a F<perlcriticrc> file in the C<use> pragma.  For example:

  use Test::Perl::Critic (-profile => 't/perlcriticrc');
  all_critic_ok();

Now place a copy of your own F<.perlcritic> file in the distribution
as F<t/perlcriticrc>.  Then, C<critc_ok()> will be run on all Perl
files in this distribution using this same Perl::Critic configuration.
See the L<Perl::Critic> documentation for details on the
F<.perlcriticrc> file format.

=head1 DIAGNOSTIC DETAILS

By default, Test::Perl::Critic displays basic information about each
Policy violation in the diagnostic output of the test.  You can
customize the format and content of this information by giving the
C<-format> option to the C<use> pragma.  For example:

  use Test::Perl::Critic (-format => "%m at line %l, column %c.");
  all_critic_ok();

Formats are a combination of literal and escape characters similar to
the way C<sprintf> works.  See L<String::Format> for a full
explanation of the formatting capabilities.  Valid escape characters
are:

  Escape    Meaning
  -------   -----------------------------------------------------
  %m        Brief description of the violation
  %f        Name of the file where the violation occurred.
  %l        Line number where the violation occurred
  %c        Column number where the violation occurred
  %e        Explanation of violation or page numbers in PBP
  %d        Full diagnostic discussion of the violation
  %p        Name of the Policy module that created the violation

=head1 EXPORTS

  critic_ok()
  all_critic_ok()

=head1 BUGS

Please report all bugs to L<http://rt.cpan.org>.  Thanks.

=head1 SEE ALSO

L<Perl::Critic>

L<Test::More>

=head1 CREDITS

Andy Lester, whose L<Test::Pod> module provided most of the code and
documentation for Test::Critic.  Thanks, Andy.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
