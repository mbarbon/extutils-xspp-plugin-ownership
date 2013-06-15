#ifndef _XSPP_PLUGIN_OWNERSHIP_DECLARATION_H
#define _XSPP_PLUGIN_OWNERSHIP_DECLARATION_H

namespace Xsp { namespace Plugin { namespace Ownership
{
    struct Magic
    {
        Magic() : object(0), perl_owned(false) { }

        void *object;
        bool perl_owned;
    };

    Magic *xsp_get_magic(pTHX_ SV *object);
    Magic *xsp_get_or_create_magic(pTHX_ SV *object);

    void xsp_set_perl_owned(pTHX_ SV *object, bool perl_owned);
    bool xsp_is_perl_owned(pTHX_ SV *object);
}}} // namespaces

#endif // _XSPP_PLUGIN_OWNERSHIP_DECLARATION_H
