package My::ModuleBuild;

use strict;
use warnings;
use base qw( Alien::Base::ModuleBuild );
use Capture::Tiny qw( capture );
use Config;
use File::Temp qw( tempdir );
use File::chdir;
use File::Spec;

sub alien_check_installed_version
{
  my($self) = @_;

  my @other;
  
  if($^O eq 'MSWin32')
  {
    if($self->invoked_action ne 'Build_PL')
    {
      require Alien::MSYS;
      my $path = File::Spec->catfile(Alien::MSYS::msys_path(), 'make');
      $path =~ s/\\/\//g;
      unshift @other, $path;
    }
  }
  
  foreach my $try ($Config{gmake}, $Config{make}, 'gmake', 'make', @other)
  {
    my($stdout, $stderr) = capture {
      system $try, '--version';
    };
    if($stdout =~ /GNU Make ([0-9.]+)/)
    {
      my $version = $1;
      $self->config_data( gmake_called => $try );
      return $version;
    }
  }

  if($^O eq 'MSWin32')
  {
    if($self->invoked_action eq 'Build_PL')
    {
      $self->_add_prereq( 'requires', 'Alien::MSYS', '0.07' );
      return 'calculated later';
    }
  }
  
  return;
}

sub alien_check_built_version
{
  shift->config_data( gmake_called => 'gmake' );
  $CWD[-1] =~ /^make-(.*)$/ ? $1 : 'unknown';
}

1;
