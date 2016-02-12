module test_dll_ctor_b;

import core.stdc.stdio      : printf;
import core.sys.windows.dll : SimpleDllMain;

mixin SimpleDllMain;

shared static this()
{
    printf("shared module ctor of b\n");
}

shared static ~this()
{
    printf("shared module dtor of b\n");
}

static this()
{
    printf("module ctor of b\n");
}

static ~this()
{
    printf("module dtor of b\n");
}

export void funcInB()
{
}