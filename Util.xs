/* This file is part of the Scalar::Vec::Util Perl module.
 * See http://search.cpan.org/dist/Scalar-Vec-Util/ */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define __PACKAGE__ "Scalar::Vec::Util"

#include "bitvect.h"

STATIC const char svu_error_invarg[] = "Invalid argument";

/* --- XS ------------------------------------------------------------------ */

MODULE = Scalar::Vec::Util              PACKAGE = Scalar::Vec::Util

PROTOTYPES: ENABLE

BOOT:
{
 HV *stash = gv_stashpv(__PACKAGE__, 1);
 newCONSTSUB(stash, "SVU_PP",   newSVuv(0));
 newCONSTSUB(stash, "SVU_SIZE", newSVuv(SVU_SIZE));
}

void
vfill(SV *sv, SV *ss, SV *sl, SV *sf)
PREINIT:
 size_t s, l, n, o;
 char f, *v;
CODE:
 if (!SvOK(sv) || !SvOK(ss) || !SvOK(sl) || !SvOK(sf)) {
  croak(svu_error_invarg);
 }

 l = SvUV(sl);
 if (!l) { XSRETURN(0); }
 s = SvUV(ss);
 f = SvTRUE(sf);
 if (SvTYPE(sv) < SVt_PV) { SvUPGRADE(sv, SVt_PV); }

 n = BV_SIZE(s + l);
 o = SvLEN(sv);
 if (n > o) {
  v = SvGROW(sv, n);
  Zero(v + o, n - o, char);
 } else {
  v = SvPVX(sv);
 }
 if (SvCUR(sv) < n) {
  SvCUR_set(sv, n);
 }

 bv_fill(v, s, l, f);

 XSRETURN(0);

void
vcopy(SV *sf, SV *sfs, SV *st, SV *sts, SV *sl)
PREINIT:
 size_t fs, ts, l, lf = 0, n, o;
 char *t, *f;
CODE:
 if (!SvOK(sf) || !SvOK(sfs) || !SvOK(st) || !SvOK(sts) || !SvOK(sl)) {
  croak(svu_error_invarg);
 }

 l  = SvUV(sl);
 if (!l) { XSRETURN(0); }
 fs = SvUV(sfs);
 ts = SvUV(sts);
 if (SvTYPE(sf) < SVt_PV) { SvUPGRADE(sf, SVt_PV); }
 if (SvTYPE(st) < SVt_PV) { SvUPGRADE(st, SVt_PV); }

 n  = BV_SIZE(ts + l);
 o  = SvLEN(st);
 if (n > o) {
  t = SvGROW(st, n);
  Zero(t + o, n - o, char);
 } else {
  t = SvPVX(st);
 }
 if (SvCUR(st) < n) {
  SvCUR_set(st, n);
 }
 f = SvPVX(sf); /* We do it there in case st == sf. */

 n  = BV_SIZE(fs + l);
 o  = SvLEN(sf);
 if (n > o) {
  lf = fs + l - o * CHAR_BIT;
  l  = o * CHAR_BIT - fs;
 }

 if (f == t) {
  bv_move(f, ts, fs, l);
 } else {
  bv_copy(t, ts, f, fs, l);
 }

 if (lf) {
  bv_fill(t, ts + l, lf, 0);
 }

 XSRETURN(0);

SV *
veq(SV *sv1, SV *ss1, SV *sv2, SV *ss2, SV *sl)
PREINIT:
 size_t s1, s2, l, o, n;
 char *v1, *v2;
CODE:
 if (!SvOK(sv1) || !SvOK(ss1) || !SvOK(sv2) || !SvOK(ss2) || !SvOK(sl)) {
  croak(svu_error_invarg);
 }

 l  = SvUV(sl);
 s1 = SvUV(ss1);
 s2 = SvUV(ss2);
 if (SvTYPE(sv1) < SVt_PV) { SvUPGRADE(sv1, SVt_PV); }
 if (SvTYPE(sv2) < SVt_PV) { SvUPGRADE(sv2, SVt_PV); }

 n  = BV_SIZE(s1 + l);
 o  = SvLEN(sv1);
 if (n > o) {
  l = o * CHAR_BIT - s1;
 }

 n  = BV_SIZE(s2 + l);
 o  = SvLEN(sv2);
 if (n > o) {
  l = o * CHAR_BIT - s2;
 }

 v1 = SvPVX(sv1);
 v2 = SvPVX(sv2);

 RETVAL = newSVuv(bv_eq(v1, s1, v2, s2, l));
OUTPUT:
 RETVAL
