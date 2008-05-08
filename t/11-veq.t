#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';

use Scalar::Vec::Util qw/veq SVU_SIZE/;

eval { veq undef, 0, my $y, 0, 0 };
like($@, qr/Invalid\s+argument/, 'first argument undef croaks');
eval { veq my $x, undef, my $y, 0, 0 };
like($@, qr/Invalid\s+argument/, 'second argument undef croaks');
eval { veq my $x, 0, undef, 0, 0 };
like($@, qr/Invalid\s+argument/, 'third argument undef croaks');
eval { veq my $x, 0, my $y, undef, 0 };
like($@, qr/Invalid\s+argument/, 'fourth argument undef croaks');
eval { veq my $x, 0, my $y, 0, undef };
like($@, qr/Invalid\s+argument/, 'fifth argument undef croaks');

my $p = SVU_SIZE;
$p = 8 if $p < 8;
my $n = 3 * $p;
my $q = 1;

*myfill = *Scalar::Vec::Util::vfill_pp;

sub rst { myfill($_[0], 0, $n, 0) }
  
sub pat {
 (undef, my $a, my $b, my $x) = @_;
 myfill($_[0], 0, $a, $x);
 myfill($_[0], $a, $b, 1 - $x);
 myfill($_[0], $a + $b, $n - ($a + $b) , $x);
}  

my ($v1, $v2) = ('') x 2;

my @s = ($p - $q) .. ($p + $q);
for my $s1 (@s) {
 for my $s2 (@s) {
  for my $l (0 .. $n - 1) {
   last if $s1 + $l > $n or $s2 + $l > $n;
   pat $v1, $s1, $l, 0;
   pat $v2, $s2, $l, 0;
   ok(veq($v1 => $s1, $v2 => $s2, $l), "veq $s1, $s2, $l");
   ok(!veq($v1 => $s1 - 1, $v2 => $s2, $l), 'not veq_pp ' . ($s1 - 1) . ", $s2, $l") if $l > 0;
   ok(!veq($v1 => $s1 + 1, $v2 => $s2, $l), 'not veq_pp ' . ($s1 + 1) . ", $s2, $l") if $l > 0;
  }
 }
}
