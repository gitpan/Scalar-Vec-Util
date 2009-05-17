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

my @DEFINES;

sub is_little_endian {
 my $order = $Config{byteorder};
 return 0 unless $order;
 my $len = length $order;
 if ($len > 8) {
  $order = substr $order, 0, 8;
  $len   = 8;
 }
 return $order eq (join '', 1 .. $len);
}

my $unit = { bits => 8, size => 1 };
if (not is_little_endian()) {
 print "Forcing unit size of 8 on non-little-endian systems.\n";
} else {
 print "Checking unit size in bits... ";
 my $align = $Config{alignbytes} || 1;
 my @bits = (8, 16, 32, 64);
 for my $bits (@bits) {
  my $size = $Config{"u${bits}size"};
  next unless $size;
  $unit = { bits => $bits, size => $size } if $size && $size <= $align;
 }
 print $unit->{bits},
                " (actually $unit->{size} bytes for $align bytes alignment).\n";
}

{
 my $bits = $unit->{bits};
 push @DEFINES, '-DBV_UNIT="' . ($Config{"u${bits}type"} || "U$bits") . '"';
 push @DEFINES, "-DSVU_SIZE=$bits";
}

@DEFINES = (DEFINE => join ' ', @DEFINES) if @DEFINES;

my $dist = 'Scalar-Vec-Util';

my %META = (
 configure_requires => {
  'Config'              => 0,
  'ExtUtils::MakeMaker' => 0,
  'File::Spec'          => 0,
 },
 build_requires => {
  'Config'              => 0,
  'ExtUtils::MakeMaker' => 0,
  'Test::More'          => 0,
 },
 resources => {
  bugtracker => "http://rt.cpan.org/NoAuth/ReportBug.html?Queue=$dist",
  homepage   => "http://search.cpan.org/dist/$dist/",
  license    => 'http://dev.perl.org/licenses/',
  repository => "http://git.profvince.com/?p=perl%2Fmodules%2F$dist.git",
 },
);

WriteMakefile(
    NAME             => 'Scalar::Vec::Util',
    AUTHOR           => 'Vincent Pit <perl@profvince.com>',
    LICENSE          => 'perl',
    VERSION_FROM     => 'lib/Scalar/Vec/Util.pm',
    ABSTRACT_FROM    => 'lib/Scalar/Vec/Util.pm',
    PL_FILES         => {},
    C                => \@C,
    @DEFINES,
    PREREQ_PM        => {
        'Exporter' => 0,
        'Carp'     => 0,
        'XSLoader' => 0
    },
    MIN_PERL_VERSION => 5.006,
    META_MERGE       => \%META,
    dist             => {
        PREOP    => 'pod2text lib/Scalar/Vec/Util.pm > $(DISTVNAME)/README',
        COMPRESS => 'gzip -9f', SUFFIX => 'gz'
    },
    clean            => {
        FILES => "$dist-* *.gcov *.gcda *.gcno cover_db Debian_CPANTS.txt"
    },
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
