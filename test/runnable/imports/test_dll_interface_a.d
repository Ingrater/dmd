module test_dll_interface_a;

import core.stdc.stdio;
import core.sys.windows.dll;

mixin SimpleDllMain!(DllIsUsedFromC.no);

export __gshared int[3] g_arr = [1, 2, 3];

export extern(C) int* g_arr_addr(size_t index)
{
    return g_arr.ptr + index;
}

interface IInterface
{
    int getMember();
}

export class Base : IInterface // should export vartable and typeinfo
{
private:
    __gshared int s_var_1 = 4; // should not be exported

    static void setVar1(int i) // should not be exported
    {
        s_var_1 = i;
    }

    int m_i; // should not be exported

protected:
    __gshared int s_var_2 = 5; // should be exported

    static void setVar2(int i) // should be exported
    {
        s_var_2 = i;
    }

    void setMember(int i) // should be exported
    {
        m_i = i;
    }

public:
    __gshared int s_var_3 = 6; // should be exported
    __gshared s_destroyCount = 0;

    ~this()
    {
        s_destroyCount++;
        m_i = 666;
    }

    int getMember() // should be exported
    {
        return m_i;
    }
}

export auto addressOfBaseGetMember()
{
    return &Base.getMember;
}

export auto makeNested(int arg)
{
    int j = arg;
    export struct Nested
    {
        int var = 1;
        int get()
        {
            return var + j;
        }
    }
    return Nested();
}

export __gshared Base g_ptr;
Base tls_ptr_impl;

export void tls_ptr(Base value)
{
  tls_ptr_impl = value;
}

export ref Base tls_ptr()
{
    return tls_ptr_impl;
}

export struct UDVT
{
    int i = 1337;
}

export struct OpBinary(string op)
{
    static int exec(int lh, int rh)
    {
        return mixin("lh" ~ op ~ "rh");
    }
}

alias OpAdd = OpBinary!"+";
alias OpMinus = OpBinary!"-";

export void throws()
{
    throw new Exception("Test Exception");
}

enum Operation
{
    add = 1,
    sub = 2
}

auto templatedSwitch(T)(T arg1, T arg2, Operation op)
{
    final switch(op)
    {
    case Operation.add:
        return arg1 + arg2;
    case Operation.sub:
        return arg1 - arg2;
    }
}

export struct Appender(T)
{
    private struct Data
    {
        size_t capacity;
        T[] arr;
        bool canExtend = false;
    }

    private Data* _Data;

    this(T[] arr)
    {
        _Data = new Data;
    }
}

export Appender!T makeAppender(T)(T[] arr)
{
    return Appender!T(arr);
}

export Appender!char getCharAppender()
{
    return makeAppender(['a', 'b', 'c']);
}

export interface IFunc1
{
    void func1();
}

export interface IFunc2
{
    void func2();
}

export interface IFunc3
{
    void func3();
}

export struct TemplatedStruct(T)
{
public:
    T member;

    void setMember(U)(U value)
    {
        member = value;
    }

    alias defaultSetterType = void delegate(T value);

    defaultSetterType defaultSetter;

    void init()
    {
        defaultSetter = &this.setMember!T;
    }

    static struct Inner(U)
    {
        U anotherMember;

        void init()
        {
            anotherMember = 0;
        }
    }

    Inner!T inner;
}

export __gshared TemplatedStruct!int g_templatedStructInstance;
export __gshared TemplatedStruct!int.Inner!int g_templatedStructInnerInstance;

extern(C) int lotsAfAttributes() @trusted pure nothrow @nogc export
{
    return 1337;
}

export enum EditOp : char
{
    none = 'n',
    substitute = 's',
    insert = 'i',
    remove = 'r'
}

export int duplicatedFunc(T)()
{
  return T.sizeof;
}