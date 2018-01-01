module test_dll_interface_c;
pragma(sharedlibrary, "c");

import core.sys.windows.dll;

mixin SimpleDllMain!(DllIsUsedFromC.no);

extern(C) export __gshared int c_moduleCtorCalled = 0;
extern(C) export __gshared void function() c_moduleDtorCalled;

shared static this()
{
    c_moduleCtorCalled = 1;
}

shared static ~this()
{
    c_moduleDtorCalled();
}

__gshared int g_var1;
int g_var2;

alias callback_t = void function();

__gshared callback_t g_func;
__gshared callback_t g_tls_func;

__gshared Object g_object;
Object g_tls_object;

shared static this()
{
    g_var1 = 1337;
}

static this()
{
    g_var2 = 1338;
}

static ~this()
{
    if(g_tls_func !is null)
        g_tls_func();
}

shared static ~this()
{
    if(g_func !is null)
        g_func();
}

export:
extern(C):

int get_var1()
{
    return g_var1;
}

int get_var2()
{
    return g_var2;
}

void setCallback(callback_t func)
{
    g_func = func;
}

void setTlsCallback(callback_t func)
{
    g_tls_func = func;
}

void setObject(Object obj)
{
    g_object = obj;
}

void setTlsObject(Object obj)
{
    g_tls_object = obj;
}