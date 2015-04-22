package My::ModuleBuild;

use strict;
use warnings;
use base qw( Alien::Base::ModuleBuild );
use Capture::Tiny qw( capture );
use Config;
use File::Temp qw( tempdir );
use File::chdir;

sub new
{
  my($class, %args) = @_;
  
  $args{alien_name} = 'gmake';
  $args{alien_stage_install} = 1;
  $args{alien_build_commands} = [
    '%c --prefix=%s --program-prefix=g',
    "make",
  ];
  $args{alien_install_commands} = [
    "make install",
  ];
  $args{alien_repository} = {
    protocol => 'http',
    host     => 'ftp.gnu.org',
    location => "/gnu/make/",
    pattern  => qr{^make-.*\.tar\.gz$},
  };
  
  my $self = $class->SUPER::new(%args);
  
  $self;
}

sub alien_check_installed_version
{
  my($self) = @_;
  
  foreach my $try ($Config{gmake}, $Config{make}, 'gmake', 'make')
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
  
  return;
}

sub alien_check_built_version
{
  shift->config_data( gmake_called => 'gmake' );
  $CWD[-1] =~ /^make-(.*)$/ ? $1 : 'unknown';
}

1;
