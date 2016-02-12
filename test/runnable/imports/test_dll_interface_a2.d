module test_dll_interface_a2;

import test_dll_interface_a;

export void causeDuplicateSymbol()
{
    assert(duplicatedFunc!int() == int.sizeof);
}