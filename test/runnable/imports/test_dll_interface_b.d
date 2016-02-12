module test_dll_interface_b;

import test_dll_interface_a;
import core.sys.windows.dll;

mixin SimpleDllMain!(DllIsUsedFromC.no);


export interface IFunc4 : IFunc1, IFunc2
{
    void func4();
}