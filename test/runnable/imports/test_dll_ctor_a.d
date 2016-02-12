module test_dll_ctor_a;

import test_dll_ctor_b;

import core.stdc.stdio      : printf;
import core.sys.windows.dll : SimpleDllMain;

mixin SimpleDllMain;

shared static this()
{
    printf("shared module ctor of a\n");
}

shared static ~this()
{
    printf("shared module dtor of a\n");
}

static this()
{
    printf("module ctor of a\n");
}

static ~this()
{
    printf("module dtor of a\n");
}

export void funcInA()
{

}