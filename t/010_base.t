#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 2;

run_diff xsp_stdout => 'expected';

__DATA__

=== Class declaration
--- xsp_stdout
%module{Foo};

%loadplugin{Ownership};

class Foo %catch{nothing}
{
    %DestroyIfOwned;
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

void
Foo::DESTROY()
  CODE:
            if (Xsp::Plugin::Ownership::xsp_is_perl_owned(aTHX_ ST(0)))
            delete THIS;

=== Return type
--- xsp_stdout
%module{Foo};

%loadplugin{Ownership};

class Foo %catch{nothing}
{
    int foo( int a, int b, int c ) %TransferToPerl;
    int bar( int a, int b, int c ) %TransferToCpp;
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( int a, int b, int c )
  CODE:
    try {
      RETVAL = THIS->foo( a, b, c );
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL
  CLEANUP:
    Xsp::Plugin::Ownership::xsp_set_perl_owned(aTHX_ ST(0), true);

int
Foo::bar( int a, int b, int c )
  CODE:
    try {
      RETVAL = THIS->bar( a, b, c );
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL
  CLEANUP:
    Xsp::Plugin::Ownership::xsp_set_perl_owned(aTHX_ ST(0), false);
