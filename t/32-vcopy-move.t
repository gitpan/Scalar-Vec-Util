#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';

use Scalar::Vec::Util qw/vcopy SVU_SIZE/;

my $p = SVU_SIZE;
$p = 8 if $p < 8;
my $n = 3 * $p;
my $q = 1;

*myfill = *Scalar::Vec::Util::vfill_pp;
*myeq   = *Scalar::Vec::Util::veq_pp;

sub rst { myfill($_[0], 0, $n, 0); $_[0] = '' }

sub pat {
 (undef, my $a, my $b, my $x) = @_;
 unless ($b) {
  rst $_[0];
 } else {
  $_[0] = '';
  myfill($_[0], 0,       $a,             $x);
  myfill($_[0], $a,      $b,             1 - $x);
  myfill($_[0], $a + $b, $n - ($a + $b), $x) if $a + $b < $n;
 }
}

sub prnt {
 (undef, my $n, my $desc) = @_;
 my $i = 0;
 my $s;
 $s .= vec($_[0], $i++, 1) while $i < $n;
 diag "$desc: $s";
}

my ($v, $c) = ('') x 2;

my @s = (0 .. $q, ($p - $q) .. ($p + $q));
for my $s1 (@s) {
 for my $s2 (@s) {
  for my $l (0 .. $n - 1) {
   for my $x (0 .. $q) {
    for my $y (0 .. $q) {
     last if $s1 + $l + $x > $n or $s1 + $x + $y > $l
          or $s2 + $l + $x > $n or $s2 + $x + $y > $l;
     pat $v, $s1 + $x, $l - $x - $y, 0;
     my $v0 = $v;
     $c = $v;
     myfill($c, $s2,           $x,           0) if $x;
     myfill($c, $s2 + $x,      $l - $x - $y, 1);
     myfill($c, $s2 + $l - $y, $y,           0) if $y;
     vcopy $v => $s1, $v => $s2, $l;
     ok(myeq($v, 0, $c, 0, $n), "vcopy [ $x, $y ], $s1, $s2, $l (move)") or do {
      diag "n = $n, s1 = $s1, s2 = $s2, l = $l, x = $x, y = $y";
      prnt $v0, $n, 'original';
      prnt $v,  $n, 'got     ';
      prnt $c,  $n, 'expected';
     };
     is(length $v, length $c, "length is ok");
    }
   }
  }
 }
}
