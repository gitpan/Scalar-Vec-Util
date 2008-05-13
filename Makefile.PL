use 5.006;

use strict;
use warnings;
use ExtUtils::MakeMaker;

BEGIN {
 eval { require Config };
 die 'OS unsupported' if $@;
 Config->import(qw/%Config/);
 eval { require File::Spec };
 die 'OS unsupported' if $@;
}

# Inspired from Module::Install::Can
print "Checking for a valid C compiler in the PATH... ";
my @ccs = ($Config{cc});
unshift @ccs, $ENV{CC} if $ENV{CC};
my $cc;
CC:
for my $c (@ccs) {
 for my $dir (split /$Config{path_sep}/, $ENV{PATH}) {
  my $abs = File::Spec->catfile($dir, $c);
  if (-x $abs or MM->maybe_command($abs)) {
   $cc = $c;
   last CC;
  }
 }
}
my @C;
if ($cc) {
 push @C, 'Util.c';
 print $cc, "\n";
} else {
 print "none\n";
}

my $arch = $Config{archname} || '';
my ($cpu) = $arch =~ /^([^-]+)/;

my @DEFINES;
my $unit = 8;
if (unpack("h*", pack("s", 0x1234)) != 4321) {
 print "Forcing unit size of 8 on non-little-endian systems.\n";
} else {
 my $align = int($Config{alignbytes} || 0);
 print "Checking unit size in bits... ";
 my @s = (8, 16, 32);
 push @s, 64 unless $^O eq 'MSWin32';
 for (@s) {
  my $size = int($Config{'u' . $_ . 'size'} || 0);
  $unit = $_ if $size && $size <= $align;
 }
 print $unit, "\n";
}
push @DEFINES, DEFINE => '-DBV_UNIT="'
                                 . ($unit == 64 ? 'uint64_t' : 'U' . $unit)
                                 . '"'
                      . ' -DSVU_SIZE=' . $unit;

my $BUILD_REQUIRES = {
 'Config'              => 0,
 'ExtUtils::MakeMaker' => 0,
 'File::Spec'          => 0,
 'Test::More'          => 0,
};

sub build_req {
 my $tometa = ' >> $(DISTVNAME)/META.yml;';
 my $build_req = 'echo "build_requires:" ' . $tometa;
 foreach my $mod ( sort { lc $a cmp lc $b } keys %$BUILD_REQUIRES ) {
  my $ver = $BUILD_REQUIRES->{$mod};
  $build_req .= sprintf 'echo "    %-30s %s" %s', "$mod:", $ver, $tometa;
 }
 return $build_req;
}

WriteMakefile(
    NAME          => 'Scalar::Vec::Util',
    AUTHOR        => 'Vincent Pit <perl@profvince.com>',
    LICENSE       => 'perl',
    VERSION_FROM  => 'lib/Scalar/Vec/Util.pm',
    ABSTRACT_FROM => 'lib/Scalar/Vec/Util.pm',
    PL_FILES      => {},
    C             => \@C,
    @DEFINES,
    PREREQ_PM     => {
        'Exporter' => 0,
        'Carp'     => 0,
        'XSLoader' => 0
    },
    dist          => {
        PREOP      => 'pod2text lib/Scalar/Vec/Util.pm > $(DISTVNAME)/README; '
                      . build_req,
        COMPRESS   => 'gzip -9f', SUFFIX => 'gz'
    },
    clean         => { FILES => 'Scalar-Vec-Util-* *.gcov *.gcda *.gcno cover_db' },
);

1;

package MY;

sub postamble {
 my $cv = join ' -coverage ', 'cover',
                            qw/statement branch condition path subroutine time/;
 <<POSTAMBLE;
cover test_cover:
	$cv -test
POSTAMBLE
}
