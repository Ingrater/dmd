module test_dll_interface_d;

export int staticLibFunc()
{
    return 5;
}

export __gshared int g_staticLibVar = 10;

export int* getStaticLibVarAddr()
{
    return &g_staticLibVar;
}