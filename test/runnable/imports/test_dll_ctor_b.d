module test_dll_ctor_b;
pragma(sharedlibrary, "b");

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