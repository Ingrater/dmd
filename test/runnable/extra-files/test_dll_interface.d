module test_dll_interface;

import test_dll_interface_a;
import test_dll_interface_b;

import core.stdc.stdio;
import core.exception;

class Derived : Base
{
    Base* m_evilMember = &g_ptr;

  public:

    this()
    {
        setVar2(7);
    }

    void setMemberImpl(int i)
    {
        setMember(i);
    }

    static int getVar2()
    {
        return s_var_2;
    }
}

class InterfaceTest : IFunc4, IFunc3
{
  public:
    override void func1(){}
    override void func2(){}
    override void func3(){}
    override void func4(){}
}

void TestInterfaceTest()
{
    auto info = typeid(InterfaceTest);
    auto iface1 = info.interfaces[0].classinfo;
    auto iface1_should = typeid(IFunc4).info;
    assert(iface1 == iface1_should);

    auto iface2 = info.interfaces[0].classinfo.interfaces[0].classinfo;
    auto iface2_should = typeid(IFunc1).info;
    assert(iface2 == iface2_should);

    auto iface3 = info.interfaces[1].classinfo;
    auto iface3_should = typeid(IFunc2).info;
    assert(iface3 == iface3_should);

    auto iface4 = info.interfaces[2].classinfo;
    auto iface4_should = typeid(IFunc3).info;
    assert(iface4 == iface4_should);
}

struct UseDefinedValueType
{
    Base* evilMember = &g_ptr;
}

__gshared Base g_exe_ptr;
Base tls_exe_ptr;

string GCerror(int shouldBe)
{
    printf("destroyCount is %d but should be %d\n", Base.s_destroyCount, shouldBe);
    return "destroyCount has unexpected value";
}

void makeBase(ref Base target)
{
    target = new Base();
    int sum = clearStackAndRAX();
}

int clearStackAndRAX()
{
    int[2000] largeArray;
    largeArray[] = 0;

    return 5;
}

void testGC()
{
    import core.memory;
    GC.collect();
    assert(Base.s_destroyCount == 0, GCerror(0));

    makeBase(g_exe_ptr);
    GC.collect();
    assert(Base.s_destroyCount == 0, GCerror(0));
    g_exe_ptr = null;
    GC.collect();
    assert(Base.s_destroyCount <= 1, GCerror(1));

    makeBase(tls_exe_ptr);
    GC.collect();
    assert(Base.s_destroyCount <= 1, GCerror(1));
    tls_exe_ptr = null;
    GC.collect();
    assert(Base.s_destroyCount <= 2, GCerror(2));

    makeBase(g_ptr);
    GC.collect();
    assert(Base.s_destroyCount <= 2, GCerror(2));
    g_ptr = null;
    GC.collect();
    assert(Base.s_destroyCount <= 3, GCerror(3));

    makeBase(tls_ptr);
    GC.collect();
    assert(Base.s_destroyCount <= 3, GCerror(3));
    tls_ptr = null;
    GC.collect();
    assert(Base.s_destroyCount <= 4, GCerror(4));
}

void testTypeInfo(T)(string expected)
{
    static string error(const(char)[] arg1, const(char)[] arg2)
    {
        printf("Type Info %.*s does not match %.*s\n", arg1.length, arg1.ptr, arg2.length, arg2.ptr);
        return "TypeInfo tests failed";
    }

    assert(typeid(T).toString == expected, error(typeid(T).toString, expected));
}

template Tuple(E...)
{
    alias Tuple = E;
}

void testTypeInfos()
{
    testTypeInfo!byte("byte");
    testTypeInfo!ubyte("ubyte");
    testTypeInfo!short("short");
    testTypeInfo!ushort("ushort");
    testTypeInfo!int("int");
    testTypeInfo!uint("uint");
    testTypeInfo!long("long");
    testTypeInfo!ulong("ulong");
    testTypeInfo!char("char");
    testTypeInfo!wchar("wchar");
    testTypeInfo!dchar("dchar");
    testTypeInfo!string("immutable(char)[]");
    testTypeInfo!wstring("immutable(wchar)[]");
    testTypeInfo!dstring("immutable(dchar)[]");
    testTypeInfo!(byte[])("byte[]");
    testTypeInfo!(ubyte[])("ubyte[]");
    testTypeInfo!(short[])("short[]");
    testTypeInfo!(ushort[])("ushort[]");
    testTypeInfo!(int[])("int[]");
    testTypeInfo!(uint[])("uint[]");
    testTypeInfo!(long[])("long[]");
    testTypeInfo!(ulong[])("ulong[]");
    testTypeInfo!(char[])("char[]");
    testTypeInfo!(wchar[])("wchar[]");
    testTypeInfo!(dchar[])("dchar[]");
    testTypeInfo!(const(void))("const(void)");
    testTypeInfo!(void[4])("void[4]");
    testTypeInfo!(const(ulong))("const(ulong)");
    testTypeInfo!(const(Base))("const(test_dll_interface_a.Base)");
}

void testUDVT(UDVT* ptr)
{
    assert(ptr.i == 1337);
}

void testException()
{
    bool thrown = false;
    try
    {
        throws();
    }
    catch(Exception ex)
    {
        thrown = true;
        assert(ex.msg == "Test Exception");
    }
    assert(thrown);
}

alias callback_t = void function();
alias sig1_t = extern(C) int function();
alias sig2_t = extern(C) void function(callback_t);
alias sig3_t = extern(C) void function(Object);


__gshared sig1_t get_var1;
__gshared sig1_t get_var2;
__gshared sig2_t setCallback;
__gshared sig2_t setTlsCallback;
__gshared sig3_t setObject;
__gshared sig3_t setTlsObject;

__gshared int* c_moduleCtorCalled;
__gshared void function()* c_moduleDtorCalled;
__gshared bool c_moduleDtorWasCalled = false;

void c_moduleDtorCallback()
{
    c_moduleDtorWasCalled = true;
}

void testDynamicLoading()
{
    import core.runtime;
    import core.sys.windows.windows;
    auto lib = cast(HMODULE)Runtime.loadLibrary("test_dll_interface_c.dll");
    assert(lib !is null);
    get_var1 = cast(sig1_t)GetProcAddress(lib, "get_var1");
    assert(get_var1 !is null);
    get_var2 = cast(sig1_t)GetProcAddress(lib, "get_var2");
    assert(get_var2 !is null);
    setCallback = cast(sig2_t)GetProcAddress(lib, "setCallback");
    assert(setCallback !is null);
    setTlsCallback = cast(sig2_t)GetProcAddress(lib, "setTlsCallback");
    assert(setTlsCallback !is null);
    setObject = cast(sig3_t)GetProcAddress(lib, "setObject");
    assert(setObject !is null);
    setTlsObject = cast(sig3_t)GetProcAddress(lib, "setTlsObject");
    assert(setTlsObject !is null);
    c_moduleCtorCalled = cast(typeof(c_moduleCtorCalled))GetProcAddress(lib, "c_moduleCtorCalled");
    assert(c_moduleCtorCalled !is null);
    c_moduleDtorCalled = cast(typeof(c_moduleDtorCalled))GetProcAddress(lib, "c_moduleDtorCalled");

    assert(*c_moduleCtorCalled == 1, "Module constructor of test_dll_interface_c.dll was not called during dynamic loading");
    *c_moduleDtorCalled = &c_moduleDtorCallback;

    bool success = Runtime.unloadLibrary(lib);
    assert(success);

    assert(c_moduleDtorWasCalled, "Module destructor of test_dll_interface_c.dll was not called during dynamic unloading");
}

void TestTemplatedNestedStruct()
{
    g_templatedStructInnerInstance.init();
    g_templatedStructInstance.setMember!int(5);
}

void TestArrayLiteralRelocation()
{
    int*[] addr = [ g_arr.ptr, g_arr.ptr + 1, g_arr.ptr + 2];
    assert(addr[0] is g_arr_addr(0));
    assert(addr[1] is g_arr_addr(1));
    assert(addr[2] is g_arr_addr(2));
}

void TestStructLiteral()
{
    assert(typeof(makeNested(1)).init.var == 1);
    auto a = [typeof(makeNested(1)).init];
    assert(a[0].var == 1);
}

void TestOpEquals()
{
	struct Foo
	{
		int a;
		void opAssign(Foo foo)
		{
			assert(0);
		}
		auto opEquals(Foo foo)
		{
			return a == foo.a;
		}
	}
  assert(Foo(1) == Foo(1));
}

void printargs(int x, ...)
{
    auto v = _arguments[0].toString();
    printf("%.*s\n", v.length, v.ptr);
}

void TestTupleTypeInfo()
{
  printargs(1, 10, 23, 40);
}

struct TestEnumInitializer2(Specs...)
{
    mixin("Specs[0] first;");
}

void TestEnumInitializer()
{
    TestEnumInitializer2!(EditOp[]) value;
}

void TestAddressOfMethod()
{
    assert(&Base.getMember is addressOfBaseGetMember());
}

void TestDuplicateSymbol()
{
    assert(duplicatedFunc!int() == int.sizeof);
}

void main(string[] args)
{
    auto b = new Base();
    printf("b.m_i = %d\n", b.getMember());
    printf("b.s_var_3 = %d\n", b.s_var_3);
    auto i = cast(IInterface)b;
    printf("i.m_i = %d\n", i.getMember());

    auto c = new Derived();
    c.setMemberImpl(6);
    assert(c.m_evilMember == &g_ptr);
    printf("c.m_i = %d\n", c.getMember());
    printf("c.s_var_2 = %d\n", c.getVar2());

    auto t = typeid(b);
    auto name = t.toString();
    printf("%.*s\n", name.length, name.ptr);

    auto t2 = typeid(Base);
    name = t2.toString();
    printf("%.*s\n", name.length, name.ptr);

    UseDefinedValueType u;
    assert(u.evilMember == &g_ptr);

    testGC();

    printf("3+5-1=%d\n",(OpBinary!"-".exec(OpBinary!"+".exec(3, 5), 1)));

    testTypeInfos();

    auto myStdin = core.stdc.stdio.stdin;

    TypeInfo ta = typeid(uint[]);
    auto tac = cast(TypeInfo_Array)ta;
    assert(tac !is null);

    UDVT udvt;
    testUDVT(&udvt);
    UDVT* udvt2 = new UDVT;
    testUDVT(udvt2);

    auto appender = getCharAppender();

    testException();

    auto msg = "Stdout test!\n";
    fwrite(msg.ptr, 1, msg.length, stdout);

    testDynamicLoading();

    assert(templatedSwitch(1, 2, Operation.add) == 3);

    bool switchErrorCaught = false;
    try {
        templatedSwitch(1, 2, Operation.add | Operation.sub);
    }
    catch(SwitchError ex)
    {
        SwitchError s = ex;
        switchErrorCaught = true;
    }
    assert(switchErrorCaught);

    TestInterfaceTest();

    TestTemplatedNestedStruct();
    TestArrayLiteralRelocation();

    assert(lotsAfAttributes() == 1337);
    TestStructLiteral();
    TestOpEquals();
    TestTupleTypeInfo();
    TestEnumInitializer();
    TestAddressOfMethod();
    TestDuplicateSymbol();
}