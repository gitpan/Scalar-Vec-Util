#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';

use Scalar::Vec::Util;

eval { Scalar::Vec::Util::vfill_pp(undef, 0, 0, 0) };
like($@, qr/Invalid\s+argument/, 'first argument undef croaks');
eval { Scalar::Vec::Util::vfill_pp(my $x, undef, 0, 0) };
like($@, qr/Invalid\s+argument/, 'second argument undef croaks');
eval { Scalar::Vec::Util::vfill_pp(my $x, 0, undef, 0) };
like($@, qr/Invalid\s+argument/, 'third argument undef croaks');
eval { Scalar::Vec::Util::vfill_pp(my $x, 0, 0, undef) };
like($@, qr/Invalid\s+argument/, 'fourth argument undef croaks');
