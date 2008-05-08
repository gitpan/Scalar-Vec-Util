#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';

use Scalar::Vec::Util qw/vcopy SVU_SIZE/;

my $p = SVU_SIZE;
$p = 8 if $p < 8;
my $n = 3 * $p;
my $q = 2;

*myfill = *Scalar::Vec::Util::vfill_pp;
*myeq   = *Scalar::Vec::Util::veq_pp;

sub rst { myfill($_[0], 0, $n, 0); $_[0] = '' }

sub pat {
 (undef, my $a, my $b, my $x) = @_;
 $_[0] = '';
 if ($b) {
  myfill($_[0], 0, $a, $x);
  myfill($_[0], $a, $b, 1 - $x);
 }
}

my ($v, $c) = ('') x 2;

my @s = ($p - $q) .. ($p + $q);
for my $s1 (@s) {
 for my $s2 (@s) {
  for my $l (0 .. $n - 1) {
   last if $s1 + $l > $n or $s2 + $l > $n;
   pat $v, $s1, $l, 0;
   $c = '';
   myfill($c, $s1, $l, 1);
   myfill($c, $s2, $l, 1);
   vcopy $v => $s1, $v => $s2, $l;
   ok(myeq($v, 0, $c, 0, $n), "vcopy $s1, $s2, $l (move)");
   is(length $v, length $c, "length is ok");
  }
 }
}
