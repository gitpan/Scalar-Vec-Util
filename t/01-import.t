#!perl -T

use strict;
use warnings;

use Test::More tests => 5;

require Scalar::Vec::Util;

for (qw/vfill vcopy veq SVU_PP SVU_SIZE/) {
 eval { Scalar::Vec::Util->import($_) };
 ok(!$@, 'import ' . $_);
}
