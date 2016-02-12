module test_dll_fixup_a;

alias BOOL = int;
alias HINSTANCE = void*;
alias ULONG = uint;
alias LPVOID = void*;

extern (Windows)
BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
    return true;
}

export __gshared int g_var = 4;
export __gshared int[3] g_arr = [1, 2, 3];

export extern(C) int* g_var_addr()
{
    return &g_var;
}

export extern(C) int get_g_var()
{
    return g_var;
}

export extern(C) int* g_arr_addr(size_t index)
{
    return g_arr.ptr + index;
}

export extern(C) void* get_g_var_addr()
{
    return cast(void*)&get_g_var;
}