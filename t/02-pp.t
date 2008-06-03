#!perl -T

use strict;
use warnings;

use Config qw/%Config/;

use Test::More tests => 4;

BEGIN {
 my $re = join '|',
           grep defined && length,
            @Config{qw/myarchname archname/}, 'arch';
 my @inc = @INC;
 @INC = grep !/(?:$re)$/, @INC;
 require Scalar::Vec::Util;
 Scalar::Vec::Util->import(qw/vfill vcopy veq SVU_PP/);
 @INC = @inc;
}

is(SVU_PP, 1, 'using pure perl subroutines');
for (qw/vfill vcopy veq/) {
 no strict 'refs';
 is(*{$_}{CODE}, *{'Scalar::Vec::Util::'.$_}{CODE}, $_ .' is ' . $_ . '_pp');
}
