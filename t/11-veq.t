#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';

use Scalar::Vec::Util qw/veq SVU_SIZE/;

for ([ 1, 'offset', -1 ], [ 3, 'offset', '-1' ], [ 4, 'length', -1 ]) {
 my @args  = ('1') x 5;
 $args[$_->[0]] = $_->[2];
 eval { &veq(@args) }; my $line = __LINE__;
 like $@, qr/^Invalid\s+negative\s+$_->[1]\s+at\s+\Q$0\E\s+line\s+$line/;
}

my $p = SVU_SIZE;
$p = 8 if $p < 8;
my $n = 3 * $p;
my $q = 1;

sub myfill {
 (undef, my $s, my $l, my $x) = @_;
 $x = 1 if $x;
 vec($_[0], $_, 1) = $x for $s .. $s + $l - 1;
}

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
   ok(!veq($v1 => $s1 - 1, $v2 => $s2, $l), 'not veq ' . ($s1 - 1) . ", $s2, $l") if $l > 0;
   ok(!veq($v1 => $s1 + 1, $v2 => $s2, $l), 'not veq ' . ($s1 + 1) . ", $s2, $l") if $l > 0;
  }
 }
}
