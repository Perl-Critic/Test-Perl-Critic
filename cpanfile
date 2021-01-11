# Validate with cpanfile-dump
# https://metacpan.org/release/Module-CPANfile
# https://metacpan.org/pod/distribution/Module-CPANfile/lib/cpanfile.pod

requires 'Carp'                    => 0;
requires 'English'                 => 0;
requires 'MCE'                     => 1.827;
requires 'Perl::Critic'            => 1.105;
requires 'Perl::Critic::Utils'     => 1.105;
requires 'Perl::Critic::Violation' => 1.105;
requires 'strict'                  => 0;
requires 'Test::Builder'           => 0.88;
requires 'warnings'                => 0;

on 'test' => sub {
    requires 'Test::More' => 0;
};


# vi:et:sw=4 ts=4 ft=perl
