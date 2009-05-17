#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';

use Scalar::Vec::Util qw/SVU_SIZE/;

for ([ 1, 'offset', -1 ], [ 3, 'offset', '-1' ], [ 4, 'length', -1 ]) {
 my @args  = ('1') x 5;
 $args[$_->[0]] = $_->[2];
 eval { &Scalar::Vec::Util::vcopy_pp(@args) }; my $line = __LINE__;
 like $@, qr/^Invalid\s+negative\s+$_->[1]\s+at\s+\Q$0\E\s+line\s+$line/;
}

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

my ($f, $t, $c) = ('') x 3;

my @s = ($p - $q) .. ($p + $q);
for my $s1 (@s) {
 for my $s2 (@s) {
  for my $l (0 .. $n - 1) {
   last if $s1 + $l > $n or $s2 + $l > $n;
   pat $f, $s1, $l, 0;
   rst $t;
   pat $c, $s2, $l, 0;
   Scalar::Vec::Util::vcopy_pp($f => $s1, $t => $s2, $l);
   is($t, $c, "vcopy_pp $s1, $s2, $l");
  }
 }
}
