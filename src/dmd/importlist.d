module dmd.importlist;

import dmd.dsymbol;
import dmd.dimport;
import dmd.visitor;
import dmd.dmodule;
import dmd.attrib;
import dmd.arraytypes;
import dmd.globals;

import core.stdc.stdio;

/*************************************
* Finds all imports in a import module
*/
extern(C++) void importModuleAnalysis(Dsymbol dsym, Prot.Kind protection = Prot.Kind.none)
{
    scope v = new ImportModuleVisitor(protection);
    dsym.accept(v);
}

private extern(C++) final class ImportModuleVisitor : Visitor
{
    alias visit = Visitor.visit;

    Prot.Kind curProtection;

    this(Prot.Kind curProtection)
    {
        this.curProtection = curProtection;
    }

    override void visit(Dsymbol dsym)
    {
    }

    override void visit(Module m)
    {
        for (size_t i = 0; i < m.members.dim; i++)
        {
            Dsymbol s = (*m.members)[i];
            s.importModuleAnalysis();
        }
    }

    override void visit(Import imp)
    {
        if(!imp.mod)
        {
            imp.lookupModule();
        }

        if (imp.mod)
        {
            if(curProtection == Prot.Kind.public_)
            {
                imp.mod.isDllImported = true;
                if (global.params.verbose)
                    fprintf(global.stdmsg, "module imported from dll %s\n", imp.mod.toChars());
            }
        }
    }

    override void visit(ProtDeclaration p)
    {
        Dsymbols* d = p.include(null);
        if(d)
        {
            for (size_t i = 0; i < d.dim; i++)
            {
                Dsymbol s = (*d)[i];
                s.importModuleAnalysis(p.protection.kind);
            }
        }
    }
}
