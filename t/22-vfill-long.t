#!perl -T

use strict;
use warnings;

use Test::More tests => 34;

use Scalar::Vec::Util qw/vfill/;

my $n = 2 ** 16;

*myfill = *Scalar::Vec::Util::vfill_pp;
*myeq   = *Scalar::Vec::Util::veq_pp;

my ($v, $c) = ('') x 2;

my $l = 1;
while ($l <= $n) {
 myfill($c, 0, $l, 1);
 vfill($v, 0, $l, 1);
 ok(myeq($v, 0, $c, 0, $l), "vfill 0, $l, 1");
 is(length $v, length $c, "length is ok");
 $l *= 2;
}
