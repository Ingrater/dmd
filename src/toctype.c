
// Copyright (c) 1999-2013 by Digital Mars
// All Rights Reserved
// written by Walter Bright
// http://www.digitalmars.com
// License for redistribution is by either the Artistic License
// in artistic.txt, or the GNU General Public License in gnu.txt.
// See the included readme.txt for details.

#include <stdio.h>
#include <stddef.h>
#include <time.h>
#include <assert.h>

#if __sun
#include <alloca.h>
#endif

#include "mars.h"
#include "module.h"
#include "mtype.h"
#include "declaration.h"
#include "statement.h"
#include "enum.h"
#include "aggregate.h"
#include "init.h"
#include "attrib.h"
#include "id.h"
#include "import.h"
#include "template.h"

#include "rmem.h"
#include "cc.h"
#include "global.h"
#include "oper.h"
#include "code.h"
#include "type.h"
#include "dt.h"
#include "cgcv.h"
#include "outbuf.h"
#include "irstate.h"

void slist_add(Symbol *s);
void slist_reset();


/***************************************
 * Convert from D type to C type.
 * This is done so C debug info can be generated.
 */

type *Type::toCtype()
{
    if (!ctype)
    {   ctype = type_fake(totym());
        ctype->Tcount++;
    }
    return ctype;
}

type *Type::toCParamtype()
{
    return toCtype();
}

type *TypeSArray::toCParamtype()
{
#if SARRAYVALUE
    return toCtype();
#else
    // arrays are passed as pointers
    return next->pointerTo()->toCtype();
#endif
}

type *TypeSArray::toCtype()
{
    if (!ctype)
        ctype = type_static_array(dim->toInteger(), next->toCtype());
    return ctype;
}

type *TypeDArray::toCtype()
{
    if (!ctype)
        ctype = type_dyn_array(next->toCtype());
    return ctype;
}


type *TypeAArray::toCtype()
{
    if (!ctype)
        ctype = type_assoc_array(key->toCtype(), next->toCtype());
    return ctype;
}


type *TypePointer::toCtype()
{
    //printf("TypePointer::toCtype() %s\n", toChars());
    if (!ctype)
        ctype = type_pointer(next->toCtype());
    return ctype;
}

type *TypeFunction::toCtype()
{   type *t;

    if (ctype)
        return ctype;

    param_t *paramtypes = NULL;
    size_t nparams = Parameter::dim(parameters);
    for (size_t i = 0; i < nparams; i++)
    {   Parameter *arg = Parameter::getNth(parameters, i);
        type *tp = arg->type->toCtype();
        if (arg->storageClass & (STCout | STCref))
        {   // C doesn't have reference types, so it's really a pointer
            // to the parameter type
            tp = type_allocn(TYref, tp);
        }
        param_append_type(&paramtypes,tp);
    }
    tym_t tyf = totym();
    t = type_alloc(tyf);
    t->Tflags |= TFprototype;
    if (varargs != 1)
        t->Tflags |= TFfixed;
    assert(next);           // function return type should exist
    t->Tnext = next->toCtype();
    t->Tnext->Tcount++;
    t->Tparamtypes = paramtypes;

    ctype = t;
    return t;
}

type *TypeDelegate::toCtype()
{
    if (!ctype)
        ctype = type_delegate(next->toCtype());
        return ctype;
}


type *TypeStruct::toCtype()
{
    if (ctype)
        return ctype;

    //printf("TypeStruct::toCtype() '%s'\n", sym->toChars());
    Symbol *s = symbol_calloc(sym->toPrettyChars());
    s->Sclass = SCstruct;
    s->Sstruct = struct_calloc();
    s->Sstruct->Salignsize = sym->alignsize;
    s->Sstruct->Sstructalign = sym->alignsize;
    s->Sstruct->Sstructsize = sym->structsize;
        s->Sstruct->Sarg1type = sym->arg1type ? sym->arg1type->toCtype() : NULL;
        s->Sstruct->Sarg2type = sym->arg2type ? sym->arg2type->toCtype() : NULL;

        if (!sym->isPOD())
            s->Sstruct->Sflags |= STRnotpod;
    if (sym->isUnionDeclaration())
        s->Sstruct->Sflags |= STRunion;

    type *t = type_alloc(TYstruct);
    t->Ttag = (Classsym *)s;            // structure tag name
    t->Tcount++;
    s->Stype = t;
    slist_add(s);
    ctype = t;

    /* Add in fields of the struct
     * (after setting ctype to avoid infinite recursion)
     */
    if (global.params.symdebug)
        for (size_t i = 0; i < sym->fields.dim; i++)
        {   VarDeclaration *v = sym->fields[i];

            symbol_struct_addField(s, v->ident->toChars(), v->type->toCtype(), v->offset);
        }

    //printf("t = %p, Tflags = x%x\n", t, t->Tflags);
    return t;
}

type *TypeEnum::toCtype()
{
    return sym->memtype->toCtype();
}

type *TypeTypedef::toCtype()
{
    return sym->basetype->toCtype();
}

type *TypeTypedef::toCParamtype()
{
    return sym->basetype->toCParamtype();
}

type *TypeClass::toCtype()
{   type *t;
    Symbol *s;

    //printf("TypeClass::toCtype() %s\n", toChars());
    if (ctype)
        return ctype;

    s = symbol_calloc(sym->toPrettyChars());
    s->Sclass = SCstruct;
    s->Sstruct = struct_calloc();
    s->Sstruct->Sflags |= STRclass;
    s->Sstruct->Salignsize = sym->alignsize;
    s->Sstruct->Sstructalign = sym->structalign;
    s->Sstruct->Sstructsize = sym->structsize;

    t = type_alloc(TYstruct);
    t->Ttag = (Classsym *)s;            // structure tag name
    t->Tcount++;
    s->Stype = t;
    slist_add(s);

    t = type_allocn(TYnptr, t);

    t->Tcount++;
    ctype = t;

    /* Add in fields of the class
     * (after setting ctype to avoid infinite recursion)
     */
    if (global.params.symdebug)
        for (size_t i = 0; i < sym->fields.dim; i++)
        {   VarDeclaration *v = sym->fields[i];

            symbol_struct_addField(s, v->ident->toChars(), v->type->toCtype(), v->offset);
        }

    return t;
}

