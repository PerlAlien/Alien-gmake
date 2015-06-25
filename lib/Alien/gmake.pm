package Alien::gmake;

use strict;
use warnings;
use base qw( Alien::Base );
use Env qw( @PATH );
use File::Spec;

# ABSTRACT: Find or build GNU Make
# VERSION

=head1 SYNOPSIS

 use Alien::gmake;
 # GNU Make should now be in your PATH if it wasn't already
 
 my $gmake = Alien::gmake->exe;
 system $gmake, 'all';
 system $gmake, 'install';

=head1 DESCRIPTION

Some packages insist on using GNU Make.  Some platforms refuse to come with GNU Make.
Sometimes you just want to be able to build packages that require GNU Make without
having to check the version of Make each time.  This module is for that.  It uses the
system provided GNU Make if it can be found.  Otherwise it will download and install
it into a directory not normally in your path so that it can be used when you 
C<use Alien::gmake>.  This way you can use it when you need it, but not muck up your
environment when you don't.

=head1 METHODS

=head2 exe

 my $gmake = Alien::gmake->exe;

Return the "name" of GNU make.  Normally this is either C<make> or C<gmake>.

=cut

my $in_path;

sub import
{
  return if __PACKAGE__->install_type('system');
  return if $in_path;
  unshift @PATH, File::Spec->catdir(__PACKAGE__->dist_dir, 'bin');
  # only do it once.
  $in_path = 1;
}

sub exe
{
  my($class) = @_;
  $class->config('gmake_called');
}

=head1 HELPERS

=head2 gmake

Returns either make or gmake depending on how GNU make is called on your 
system.

=cut

sub alien_helper
{
  return {
    gmake => sub {
      # return the executable name for GNU make,
      # usually either make or gmake depending on
      # the platform and environment
      my($class) = @_;
      $class->exe;
    },
  }
}

1;
