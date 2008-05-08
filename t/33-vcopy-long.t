#!perl -T

use strict;
use warnings;

use Test::More tests => 34 + 2;
use Config qw/%Config/;

use Scalar::Vec::Util qw/vcopy/;

my $n = 2 ** 16;

*myfill = *Scalar::Vec::Util::vfill_pp;
*myeq   = *Scalar::Vec::Util::veq_pp;

my ($v, $c) = ('') x 2;

my $l = 1;
vec($v, 0, 1) = 1;
vec($c, 0, 1) = 1;
while ($l <= $n) {
 myfill($c, $l, $l, 1);
 vcopy $v, 0, $v, $l, $l;
 $l *= 2;
 ok(myeq($v, 0, $c, 0, $l), "vcopy $l");
 is(length $v, length $c, "length is ok");
}

my ($w, $k) = ('') x 2;
$n = ($Config{alignbytes} - 1) * 8;
my $p = 4 + $n / 2;
vec($w, $_, 1)      = 1 for 0 .. $n - 1;
vec($k, $_, 1)      = 0 for 0 .. $n - 1;
vec($k, $_ - $p, 1) = 1 for $p .. $n - 1;
vcopy $w, $p, $w, 0, $n;
ok(myeq($w, 0, $k, 0, $n), "vcopy with fill");
is(length $w, length $k, "length is ok");
