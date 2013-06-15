// do not #include ownership.h
#define PERL_NO_GET_CONTEXT

namespace
{
    MGVTBL my_vtbl = { 0, 0, 0, 0, 0, 0, 0, 0 };
}

namespace Xsp { namespace Plugin { namespace Ownership
{
    Magic *xsp_get_magic(pTHX_ SV *object)
    {
        // check for reference
        if (!SvROK(object))
            return NULL;
        SV *ref = SvRV(object);

        // if it isn't a SvPVMG, then it can't have MAGIC
        if (!ref || SvTYPE(ref) < SVt_PVMG)
            return NULL;

        // search for '~' / PERL_MAGIC_ext magic, and check the value
#if PERL_SUBVERSION >= 14
        MAGIC *magic = mg_findext(ref, PERL_MAGIC_ext, &my_vtbl);
#else
        MAGIC *magic = mg_find(ref, '~');
#endif
        if (!magic)
            return NULL;

        return (Magic *) magic->mg_ptr;
    }

    Magic *xsp_get_or_create_magic(pTHX_ SV *object)
    {
        // check for reference
        if (!SvROK(object))
            croak("xsp_get_or_create_magic: object is not a reference");
        SV *ref = SvRV(object);

        // must be at least a PVMG
        if (SvTYPE(ref) < SVt_PVMG)
            SvUPGRADE(ref, SVt_PVMG);

        // search for '~' magic, and check the value
        MAGIC *magic;

#if PERL_SUBVERSION >= 14
        while (!(magic = mg_findext(ref, PERL_MAGIC_ext, &my_vtbl)))
#else
        while (!(magic = mg_find(ref, '~')))
#endif
        {
            Magic tmp;
#if PERL_SUBVERSION >= 14
            sv_magicext(ref, NULL, PERL_MAGIC_ext, &my_vtbl, (char *) &tmp, sizeof(tmp));
#else
            sv_magic(ref, NULL, '~', (char *) &tmp, sizeof(tmp));
#endif
        }

        return (Magic *) magic->mg_ptr;
    }

    void xsp_set_perl_owned(pTHX_ SV *object, bool perl_owned)
    {
        // check for reference
        if (!SvROK(object))
            return;
        SV *rv = SvRV(object);

        // non-PVMG are always Perl-owned
        if (perl_owned && SvTYPE(rv) < SVt_PVMG)
            return;

        Magic *mg = xsp_get_or_create_magic(aTHX_ object);

        mg->perl_owned = perl_owned;
    }

    bool xsp_is_perl_owned(pTHX_ SV *object)
    {
        Magic *mg = xsp_get_magic(aTHX_ object);

        return mg             ? mg->perl_owned :
               SvRV( object ) ? true           :
                                false;

    }
}}} // namespaces
