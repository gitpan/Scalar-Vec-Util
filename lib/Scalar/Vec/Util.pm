package Scalar::Vec::Util;

use strict;
use warnings;

use Carp qw/croak/;

=head1 NAME

Scalar::Vec::Util - Utility routines for vec strings.

=head1 VERSION

Version 0.02

=cut

our $VERSION;
BEGIN {
 $VERSION = '0.02';
 eval {
  require XSLoader;
  XSLoader::load(__PACKAGE__, $VERSION);
  1;
 } or do {
  sub SVU_PP   () { 1 }
  sub SVU_SIZE () { 1 }
  *vfill = *vfill_pp;
  *vcopy = *vcopy_pp;
  *veq   = *veq_pp;
 }
}

=head1 SYNOPSIS

    use Scalar::Vec::Util qw/vfill vcopy veq/;

    my $s;
    vfill $s, 0, 100, 1; # Fill with 100 bits 1 starting at 0.
    my $t;
    vcopy $s, 20, $t, 10, 30; # Copy 30 bits from $s, starting at 20,
                              #                to $t, starting at 10.
    vcopy $t, 10, $t, 20, 30; # Overalapping areas DWIM.
    if (veq $t, 10, $t, 20, 30) { ... } # Yes, they are equal now.

=head1 DESCRIPTION

A set of utilities to manipulate bits in vec strings. Highly optimized XS routines are used when available, but straightforward pure perl replacements are also provided for platforms without a C compiler.

This module doesn't reimplement bit vectors. It can be used on the very same scalars that C<vec> builds, or actually on any Perl string (C<SVt_PV>).

=head1 CONSTANTS

=head2 C<SVU_PP>

True when pure perl fallbacks are used instead of XS functions.

=head2 C<SVU_SIZE>

Size in bits of the unit used for moves. The higher this value is, the faster the XS functions are. It's usually C<CHAR_BIT * $Config{alignbytes}>, except on non-little-endian architectures where it currently falls back to C<CHAR_BIT> (e.g. SPARC).

=head1 FUNCTIONS

=head2 C<vfill $vec, $start, $length, $bit>

Starting at C<$start> in C<$vec>, fills C<$length> bits with C<$bit>. Grows C<$vec> if necessary.

=cut

sub _alldef {
 for (@_) { return 0 unless defined }
 return 1;
}

sub vfill_pp {
 (undef, my $s, my $l, my $x) = @_;
 croak "Invalid argument" unless _alldef @_;
 return unless $l;
 $x = 1 if $x;
 vec($_[0], $_, 1) = $x for $s .. $s + $l - 1;
}

=head2 C<< vcopy $from => $from_start, $to => $to_start, $length >>

Copies C<$length> bits starting at C<$from_start> in C<$from> to C<$to_start> in C<$to>. If C<$from_start + $length> is too long for C<$from>, zeros are copied past C<$length>. Grows C<$to> if necessary.

=cut

sub vcopy_pp {
 my ($fs, $ts, $l) = @_[1, 3, 4];
 croak "Invalid argument" unless _alldef @_;
 return unless $l;
 my $step = $ts - $fs;
 if ($step <= 0) { 
  vec($_[2], $_ + $step, 1) = vec($_[0], $_, 1) for $fs .. $fs + $l - 1;
 } else { # There's a risk of overwriting if $_[0] and $_[2] are the same SV.
  vec($_[2], $_ + $step, 1) = vec($_[0], $_, 1) for reverse $fs .. $fs + $l - 1;
 }
}

=head2 C<< veq $v1 => $v1_start, $v2 => $v2_start, $length >>

Returns true if the C<$length> bits starting at C<$v1_start> in C<$v1> and C<$v2_start> in C<$v2> are equal, and false otherwise. If needed, C<$length> is decreased to fit inside C<$v1> and C<$v2> boundaries.

=cut

sub veq_pp {
 my ($s1, $s2, $l) = @_[1, 3, 4];
 croak "Invalid argument" unless _alldef @_;
 my $i = 0;
 while ($i < $l) {
  return 0 if vec($_[0], $s1 + $i, 1) != vec($_[2], $s2 + $i, 1);
  ++$i;
 }
 return 1;
}

=head1 EXPORT

The functions L</vfill>, L</vcopy> and L</veq> are only exported on request. All of them are exported by the tags C<':funcs'> and C<':all'>.

The constants L</SVU_PP> and L</SVU_SIZE> are also only exported on request. They are all exported by the tags C<':consts'> and C<':all'>.

=cut

use base qw/Exporter/;

our @EXPORT         = ();
our %EXPORT_TAGS    = (
 'funcs'  => [ qw/vfill vcopy veq/ ],
 'consts' => [ qw/SVU_PP SVU_SIZE/ ]
);
our @EXPORT_OK      = map { @$_ } values %EXPORT_TAGS;
$EXPORT_TAGS{'all'} = [ @EXPORT_OK ];

=head1 CAVEATS

Please report architectures where we can't use the alignment as the move unit. I'll add exceptions for them.

=head1 DEPENDENCIES

L<Carp>, L<Exporter> (core modules since perl 5), L<XSLoader> (since perl 5.006).

=head1 SEE ALSO

L<Bit::Vector> gives a complete reimplementation of bit vectors.

=head1 AUTHOR

Vincent Pit, C<< <perl at profvince.com> >>, L<http://www.profvince.com>.

You can contact me by mail or on #perl @ FreeNode (vincent or Prof_Vince).

=head1 BUGS

Please report any bugs or feature requests to C<bug-scalar-vec-util at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Scalar-Vec-Util>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Scalar::Vec::Util

Tests code coverage report is available at L<http://www.profvince.com/perl/cover/Scalar-Vec-Util>.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vincent Pit, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1; # End of Scalar::Vec::Util
