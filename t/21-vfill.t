#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';

use Scalar::Vec::Util qw/vfill SVU_SIZE/;

for ([ 1, 'offset', -1 ], [ 2, 'length', '-1' ]) {
 my @args  = (~0) x 4;
 $args[$_->[0]] = $_->[2];
 eval { &vfill(@args) }; my $line = __LINE__;
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

my ($v, $c) = ('') x 2;

my @s = ($p - $q) .. ($p + $q);
for my $s (@s) {
 for my $l (0 .. $n - 1) {
  next if $s + $l > $n;
  pat $c, $s, $l, 0;
  rst $v;
  vfill $v, $s, $l, 1;
  ok(myeq($v, 0, $c, 0, $n), "vfill $s, $l");
  is(length $v, length $c, "length is ok");
 }
}
