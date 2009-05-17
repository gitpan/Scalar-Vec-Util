#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';

use Scalar::Vec::Util qw/vshift SVU_SIZE/;

for ([ 1, 'offset', -1 ], [ 2, 'length', '-1' ]) {
 my @args  = ('1') x 4;
 $args[$_->[0]] = $_->[2];
 eval { &vshift(@args) }; my $line = __LINE__;
 like $@, qr/^Invalid\s+negative\s+$_->[1]\s+at\s+\Q$0\E\s+line\s+$line/;
}

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
 $x = $x ? 1 : 0;
 if (defined $b) {
  myfill($_[0], 0, $a, $x);
  myfill($_[0], $a, $b, 1 - $x);
 }
}

sub expect {
 (undef, my $s, my $l, my $b, my $left, my $insert) = @_;
 myfill($_[0], 0, $s, 0);
 if ($b < $l) {
  if ($left) {
   myfill($_[0], $s,      $b,      defined $insert ? $insert : 1);
   myfill($_[0], $s + $b, $l - $b, 1);
  } else {
   myfill($_[0], $s,           $l - $b, 1);
   myfill($_[0], $s + $l - $b, $b,      defined $insert ? $insert : 1);
  }
 } else {
  myfill($_[0], $s, $l, defined $insert ? $insert : 1);
 }
}

my ($v, $v0, $c) = ('', '') x 2;

sub try {
 my ($left, $insert) = @_;
 my @s = ($p - $q) .. ($p + $q);
 for my $s (@s) {
  for my $l (0 .. $n - 1) {
   last if $s + $l > $n;
   rst $v0;
   pat $v0, $s, $l, 0;
   my @b = (0);
   my $l2 = int($l/2);
   push @b, $l2 if $l2 != $l;
   push @b, $l + 1;
   for my $b (@b) {
    $v = $v0;
    rst $c;
    expect $c, $s, $l, $b, $left, $insert;
    $b = -$b unless $left;
    vshift $v, $s, $l => $b, $insert;
    my $i = defined $insert ? $insert : 'undef';
    ok(myeq($v, 0, $c, 0, $n), "vshift $s, $l, $b, $i");
    is(length $v, length $c, "vshift $s, $l, $b, $i length");
   }
  }
 }
}

try 1;
try 1, 0;
try 1, 1;
try 0;
try 0, 0;
try 0, 1;
