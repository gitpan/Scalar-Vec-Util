#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark qw/cmpthese/;

use lib qw{blib/arch blib/lib};
use Scalar::Vec::Util qw/vfill vcopy veq/;

my $n = 100_000;
my $i = 0;
my $x = '';

sub inc {
 ++$_[0];
 $_[0] = 0 if $_[0] >= $n;
 return $_[0];
}

print "fill:\n";
cmpthese -3, {
 vfill    => sub { vfill $x, inc($i), $n - $i, 1; },
 vfill_pp => sub { Scalar::Vec::Util::vfill_pp($x, inc($i), $n - $i, 1); }
};

$i = 0;
my $j = int $n / 2;
my $y = '';
print "\ncopy:\n";
cmpthese -3, {
 vcopy    => sub { vcopy $x, inc($i), $y, inc($j), $n - ($i > $j ? $i : $j); },
 vcopy_pp => sub { Scalar::Vec::Util::vcopy_pp($x, inc($i), $y, inc($j), $n - ($i > $j ? $i : $j)); }
};

$i = 0;
$j = int $n / 2;
print "\nmove:\n";
cmpthese -3, {
 vcopy    => sub { vcopy $x, inc($i), $x, inc($j), $n - ($i > $j ? $i : $j); },
 vcopy_pp => sub { Scalar::Vec::Util::vcopy_pp($x, inc($i), $x, inc($j), $n - ($i > $j ? $i : $j)); }
};

$i = 0;
$j = int $n / 2;
vfill $x, 0, $n, 1;
vfill $y, 0, $n, 1;
print "\neq:\n";
cmpthese -3, {
 veq    => sub { veq $x, inc($i), $y, inc($j), $n - ($i > $j ? $i : $j); },
 veq_pp => sub { Scalar::Vec::Util::veq_pp($x, inc($i), $y, inc($j), $n - ($i > $j ? $i : $j)); }
};
