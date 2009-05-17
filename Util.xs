/* This file is part of the Scalar::Vec::Util Perl module.
 * See http://search.cpan.org/dist/Scalar-Vec-Util/ */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define __PACKAGE__     "Scalar::Vec::Util"
#define __PACKAGE_LEN__ (sizeof(__PACKAGE__)-1)

#include "bitvect.h"

STATIC void svu_validate_uv(pTHX_ SV *sv, size_t *offset, const char *desc) {
#define svu_validate_uv(S, O, D) svu_validate_uv(aTHX_ (S), (O), (D))
 IV i;

 if (SvOK(sv) && SvIOK(sv)) {
  if (SvIsUV(sv))
   *offset = SvUVX(sv);
  else {
   i = SvIVX(sv);
   if (i < 0)
    goto fail;
   *offset = i;
  }
 } else {
  i = SvIV(sv);
  if (i < 0)
   goto fail;
  *offset = i;
 }

 return;

fail:
 *offset = 0;
 croak("Invalid negative %s", desc ? desc : "integer");
}

/* --- XS ------------------------------------------------------------------ */

MODULE = Scalar::Vec::Util              PACKAGE = Scalar::Vec::Util

PROTOTYPES: ENABLE

BOOT:
{
 HV *stash = gv_stashpvn(__PACKAGE__, __PACKAGE_LEN__, 1);
 newCONSTSUB(stash, "SVU_PP",   newSVuv(0));
 newCONSTSUB(stash, "SVU_SIZE", newSVuv(SVU_SIZE));
}

void
vfill(SV *sv, SV *ss, SV *sl, SV *sf)
PROTOTYPE: $$$$
PREINIT:
 size_t s, l, n, o;
 char f, *v;
CODE:
 svu_validate_uv(sl, &l, "length");
 if (!l)
  XSRETURN(0);
 svu_validate_uv(ss, &s, "offset");
 f = SvTRUE(sf);
 SvUPGRADE(sv, SVt_PV);

 n = BV_SIZE(s + l);
 o = SvLEN(sv);
 if (n > o) {
  v = SvGROW(sv, n);
  Zero(v + o, n - o, char);
 } else {
  v = SvPVX(sv);
 }
 if (SvCUR(sv) < n)
  SvCUR_set(sv, n);

 bv_fill(v, s, l, f);

 XSRETURN(0);

void
vcopy(SV *sf, SV *sfs, SV *st, SV *sts, SV *sl)
PROTOTYPE: $$$$$
PREINIT:
 size_t fs, ts, l, lf = 0, n, o;
 char *t, *f;
CODE:
 svu_validate_uv(sl, &l, "length");
 if (!l)
  XSRETURN(0);
 svu_validate_uv(sfs, &fs, "offset");
 svu_validate_uv(sts, &ts, "offset");
 SvUPGRADE(sf, SVt_PV);
 SvUPGRADE(st, SVt_PV);

 n  = BV_SIZE(ts + l);
 o  = SvLEN(st);
 if (n > o) {
  t = SvGROW(st, n);
  Zero(t + o, n - o, char);
 } else {
  t = SvPVX(st);
 }
 if (SvCUR(st) < n)
  SvCUR_set(st, n);
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
PROTOTYPE: $$$$$
PREINIT:
 size_t s1, s2, l, o, n;
 char *v1, *v2;
CODE:
 svu_validate_uv(sl, &l, "length");
 if (!l)
  XSRETURN_YES;
 svu_validate_uv(ss1, &s1, "offset");
 svu_validate_uv(ss2, &s2, "offset");
 SvUPGRADE(sv1, SVt_PV);
 SvUPGRADE(sv2, SVt_PV);

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
