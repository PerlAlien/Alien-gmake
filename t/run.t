use strict;
use warnings;
use Test::Stream -V1;
use Test::Alien;
use Alien::gmake;

plan 4;

alien_ok 'Alien::gmake';
my $run = run_ok([Alien::gmake->exe, '--version'])
  ->exit_is(0);

$run->success ? $run->note : $run->diag;
  
