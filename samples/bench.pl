#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark qw/cmpthese/;

use lib qw{blib/arch blib/lib};
use Scalar::Vec::Util qw/vfill vcopy veq/;
my $has_bv = eval "use Bit::Vector; 1" || 0;
print 'We ' . ('don\'t ' x !$has_bv) . "have Bit::Vector.\n";

my $n = 100_000;
my $i = 0;
my $x = '';

sub inc {
 ++$_[0];
 $_[0] = 0 if $_[0] >= $n;
 return $_[0];
}

sub len {
 return $n - ($_[0] > $_[1] ? $_[0] : $_[1])
}

my ($bv1, $bv2, $bv3, $bv4);
if ($has_bv) {
 ($bv1, $bv2, $bv3, $bv4) = Bit::Vector->new($n, 4);
}

print "fill:\n";
cmpthese -3, {
 vfill     => sub { vfill $x, inc($i), $n - $i, 1 },
 vfill_pp  => sub { Scalar::Vec::Util::vfill_pp($x, inc($i), $n - $i, 1) },
 (vfill_bv => sub { $bv1->Interval_Fill(inc($i), $n - 1) }) x $has_bv
};

$i = 0;
my $j = int $n / 2;
my $y = '';
print "\ncopy:\n";
cmpthese -3, {
 vcopy     => sub { vcopy $x, inc($i), $y, inc($j), len($i, $j) },
 vcopy_pp  => sub { Scalar::Vec::Util::vcopy_pp($x, inc($i), $y, inc($j), len($i, $j)) },
 (vcopy_bv => sub { $bv2->Interval_Copy($bv1, inc($j), inc($i), len($i, $j)) }) x $has_bv
};

$i = 0;
$j = int $n / 2;
print "\nmove:\n";
cmpthese -3, {
 vmove     => sub { vcopy $x, inc($i), $x, inc($j), len($i, $j) },
 vmove_pp  => sub { Scalar::Vec::Util::vcopy_pp($x, inc($i), $x, inc($j), len($i, $j)) },
 (vmove_bv => sub { $bv1->Interval_Copy($bv1, inc($j), inc($i), len($i, $j)) }) x $has_bv
};

$i = 0;
$j = int $n / 2;
vfill $x, 0, $n, 1;
vfill $y, 0, $n, 1;
if ($has_bv) {
 $bv1->Fill();
 $bv2->Fill();
}
print "\neq:\n";
cmpthese -3, {
 veq     => sub { veq $x, inc($i), $y, inc($j), len($i, $j) },
 veq_pp  => sub { Scalar::Vec::Util::veq_pp($x, inc($i), $y, inc($j), len($i, $j)) },
 (veq_bv => sub {
   inc($i);
   inc($j);
   my $l = len($i, $j);
   $bv3->Resize($l);
   $bv3->Interval_Copy($bv1, 0, $i, $l);
   $bv4->Resize($l);
   $bv4->Interval_Copy($bv2, 0, $j, $l);
   $bv3->equal($bv4);
  }) x $has_bv
};
