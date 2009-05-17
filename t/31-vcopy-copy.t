#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';

use Scalar::Vec::Util qw/vcopy SVU_SIZE/;

for ([ 1, 'offset', -1 ], [ 3, 'offset', '-1' ], [ 4, 'length', -1 ]) {
 my @args  = (~0) x 5;
 $args[$_->[0]] = $_->[2];
 eval { &vcopy(@args) }; my $line = __LINE__;
 like $@, qr/^Invalid\s+negative\s+$_->[1]\s+at\s+\Q$0\E\s+line\s+$line/;
}

my $p = SVU_SIZE;
$p = 8 if $p < 8;
my $n = 3 * $p;
my $q = 1;

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

my ($f, $t, $c) = ('') x 3;

my @s = ($p - $q) .. ($p + $q);
for my $s1 (@s) {
 for my $s2 (@s) {
  for my $l (0 .. $n - 1) {
   last if $s1 + $l > $n or $s2 + $l > $n;
   pat $f, $s1, $l, 0;
   rst $t;
   pat $c, $s2, $l, 0;
   vcopy $f => $s1, $t => $s2, $l;
   ok(myeq($t, 0, $c, 0, $n), "vcopy $s1, $s2, $l");
   is(length $t, length $c, "length is ok");
  }
 }
}
