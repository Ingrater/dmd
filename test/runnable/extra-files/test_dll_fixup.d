
module test_dll_fixup;

import test_dll_fixup_a;

extern(C)
{
    extern __gshared void* _dllrl_beg;
    extern __gshared void* _dllrl_end;
}

extern(C) int printf(in char* format, ...) nothrow;

void fixupDataSymbols()
{
    void** begin = &_dllrl_beg;
    void** end = &_dllrl_end;
    void** outer = begin;

    while(outer < end && *outer is null)
    {
        outer++; // skip leading 0s
    }

    while(outer < end)
    {
        if(*outer !is null) // skip any padding
        {
            // The address is stored as a 32-bit offset
            int* start = cast(int*)outer;
            int relAddress = (*start) + 4; // take size of the offset into account as well
            int offset = *(start+1);
            void** reconstructedAddress = cast(void**)(cast(void*)start + relAddress);
            *reconstructedAddress = (**cast(void***)reconstructedAddress) + offset;
            outer += 8 / (void*).sizeof;
        }
        else
        {
            outer++;
        }
    }
}

__gshared int* g_pvar = &g_var;
__gshared int* g_parr = g_arr.ptr + 2;
__gshared void* g_pfunc = cast(void*)&get_g_var;
__gshared int*[3] g_arrp = [g_arr.ptr, g_arr.ptr + 1, g_arr.ptr + 2];

private alias extern(C) int function(char[][] args) MainFunc;

extern (C) int _d_run_main(int argc, char **argv, MainFunc mainFunc)
{
    fixupDataSymbols();
    printf("g_var = %d == 4\n", g_var);
    if(!(g_var == 4))
        return 1;
    g_var = 5;
    printf("g_var = %d == 5\n", get_g_var());
    if(!(get_g_var() == 5))
        return 1;
    printf("&g_var = %p == %p == %p\n", g_pvar, &g_var, g_var_addr);
    if(!(g_pvar == &g_var && &g_var == g_var_addr))
        return 1;
    printf("&g_arr[2] = %p == %p == %p\n", g_parr, g_arr.ptr + 2, g_arr_addr(2));
    if(!(g_parr == g_arr.ptr + 2 && g_arr.ptr + 2 == g_arr_addr(2)))
        return 1;
    printf("&get_g_var = %p == %p == %p\n", g_pfunc, cast(void*)&get_g_var, get_g_var_addr());
    if(!(g_pfunc == cast(void*)&get_g_var && cast(void*)&get_g_var == get_g_var_addr()))
        return 1;
    printf("g_arr[]: [%p, %p, %p] == [%p, %p, %p]\n", g_arrp[0], g_arrp[1], g_arrp[2], g_arr_addr(0), g_arr_addr(1), g_arr_addr(2));
    if(!(g_arrp[0] == g_arr_addr(0)))
        return 1;
    if(!(g_arrp[1] == g_arr_addr(1)))
        return 1;
    if(!(g_arrp[2] == g_arr_addr(2)))
        return 1;

    return 0;
}

void main(string[] args)
{
}