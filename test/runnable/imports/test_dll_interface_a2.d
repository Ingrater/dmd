module test_dll_interface_a2;
pragma(sharedlibrary, "a");

import test_dll_interface_a;

export void causeDuplicateSymbol()
{
    assert(duplicatedFunc!int() == int.sizeof);
}