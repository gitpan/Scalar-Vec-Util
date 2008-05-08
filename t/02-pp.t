#!perl -T

use strict;
use warnings;

use Test::More tests => 4;

BEGIN { @INC = grep !/arch$/, @INC }
use Scalar::Vec::Util qw/vfill vcopy veq SVU_PP/;

is(SVU_PP, 1, 'using pure perl subroutines');
for (qw/vfill vcopy veq/) {
 no strict 'refs';
 is(*{$_}{CODE}, *{'Scalar::Vec::Util::'.$_}{CODE}, $_ .' is ' . $_ . '_pp');
}
