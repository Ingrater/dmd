// PERMUTE_ARGS:
// REQUIRED_ARGS: -D -w -o- -c -Ddtest_results/compilable -o-
// POST_SCRIPT: compilable/extra-files/ddocAny-postscript.sh 2630

module ddoc2630;

/// foo function - 1 example
int foo(int a, int b) { return a + b; }

///
unittest
{
    assert(foo(1, 1) == 2);
}

/// bar function - 1 example
bool bar() { return true; }

///
unittest
{
    // documented
    assert(bar());
}

/// no code
unittest
{
}

/// doo function - no examples
void doo() { }

///
private unittest
{
    // undocumented
    doo();
}

unittest
{
    // undocumented
    doo();
}

/**
add function - 3 examples

Examples:

----
assert(add(1, 1) == 2);
----
*/
int add(int a, int b) { return a + b; }

///
unittest
{
    // documented
    assert(add(3, 3) == 6);
    assert(add(4, 4) == 8);
}

unittest
{
    // undocumented
    assert(add(2, 2) + add(2, 2) == 8);
}

///
unittest
{
    // documented
    assert(add(5, 5) == 10);
    assert(add(6, 6) == 12);
}

/// class Foo
immutable pure nothrow class Foo
{
    int x;

    ///
    unittest
    {
        // another foo example
        Foo foo = new Foo;
    }
}

///
unittest
{
    Foo foo = new Foo;
}

pure
{
    const
    {
        immutable
        {
            /// some class - 1 example
            class SomeClass {}
        }
    }
}

///
unittest
{
    SomeClass sc = new SomeClass;
}

/// Outer - 1 example
class Outer
{
    /// Inner
    static class Inner
    {
    }

    ///
    unittest
    {
        Inner inner = new Inner;
    }
}

///
unittest
{
    Outer outer = new Outer;
}

/** foobar - no examples */
void foobar()
{
}

unittest
{
    foobar();
}

/**
func - 4 examples
Examples:
---
foo(1);
---

Examples:
---
foo(2);
---
*/
void foo(int x) {  }

///
unittest
{
    foo(2);
}

///
unittest
{
    foo(4);
}


void main() { }
